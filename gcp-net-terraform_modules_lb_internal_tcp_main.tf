
resource "google_compute_health_check" "hc" {
  name = "${var.name}-ilb-hc"
  tcp_health_check { port = 80 }
}

resource "google_compute_region_backend_service" "be" {
  name                  = "${var.name}-ilb-be"
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_health_check.hc.id]
  region                = var.region
  backend { group = var.backend_igm }
}

resource "google_compute_forwarding_rule" "fr" {
  name                  = "${var.name}-ilb-fr"
  load_balancing_scheme = "INTERNAL"
  ports                 = ["80"]
  network               = var.network
  subnetwork            = var.subnet
  backend_service       = google_compute_region_backend_service.be.id
  region                = var.region
}
