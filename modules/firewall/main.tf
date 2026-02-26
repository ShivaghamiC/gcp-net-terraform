#tfsec:ignore:google-compute-no-public-ingress Allowing public ingress only in DEV
locals { iap_range = "35.235.240.0/20" }

resource "google_compute_firewall" "allow_iap_ssh" {
  name      = "${var.network_name}-allow-iap-ssh"
  network   = var.network_name
  direction = "INGRESS"
  priority  = 1000
  source_ranges = [local.iap_range]
  allow { 
    protocol = "tcp" 
    ports = ["22"] 
  }
  target_service_accounts = var.ssh_target_sas
}

resource "google_compute_firewall" "allow_web" {
  name      = "${var.network_name}-allow-web"
  network   = var.network_name
  direction = "INGRESS"
  priority  = 1000
  source_ranges = var.web_source_ranges
  allow { 
    protocol = "tcp" 
    ports = ["80","443"]
  }
  target_tags = var.web_target_tags
}
