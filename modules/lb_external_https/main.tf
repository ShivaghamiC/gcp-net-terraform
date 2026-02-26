
resource "google_compute_instance_template" "tpl" {
  name_prefix = "${var.name}-tpl-"
  machine_type = var.machine_type
  tags = ["web"]
  disk { 
    source_image = "debian-cloud/debian-12" 
    auto_delete = true 
    boot = true
}
  network_interface {
    network    = var.network
    subnetwork = var.subnet
    # Optional external IP; LB does not require it
  }
  metadata_startup_script = <<-EOT
    apt-get update -y
    apt-get install -y nginx
    echo "Hello from ${var.name}" > /var/www/html/index.html
  EOT
  shielded_instance_config { enable_secure_boot = true }
}

resource "google_compute_health_check" "hc" {
  name = "${var.name}-hc"
  http_health_check { port_specification = "USE_SERVING_PORT" }
}

resource "google_compute_region_instance_group_manager" "mig" {
  name               = "${var.name}-mig"
  base_instance_name = "${var.name}-vm"
  region             = var.region
  version { instance_template = google_compute_instance_template.tpl.id }
  target_size = 2
  auto_healing_policies { health_check = google_compute_health_check.hc.id }
}

resource "google_compute_backend_service" "be" {
  name                  = "${var.name}-be"
  load_balancing_scheme = "EXTERNAL"
  protocol              = "HTTP"
  port_name             = "http"
  backend { group = google_compute_region_instance_group_manager.mig.instance_group }
  health_checks = [google_compute_health_check.hc.id]
}

resource "google_compute_url_map" "map" {
  name            = "${var.name}-map"
  default_service = google_compute_backend_service.be.id
}

resource "google_compute_managed_ssl_certificate" "cert" {
  name = "${var.name}-cert"
  managed { domains = [var.domain] }
}

resource "google_compute_target_https_proxy" "proxy" {
  name             = "${var.name}-proxy"
  ssl_certificates = [google_compute_managed_ssl_certificate.cert.id]
  url_map          = google_compute_url_map.map.id
}

resource "google_compute_global_forwarding_rule" "fr" {
  name                  = "${var.name}-fr"
  port_range            = "443"
  target                = google_compute_target_https_proxy.proxy.id
  load_balancing_scheme = "EXTERNAL"
  ip_protocol           = "TCP"
}
