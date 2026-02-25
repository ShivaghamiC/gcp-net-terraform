
resource "google_service_account" "sa" {
  account_id   = var.sa_id
  display_name = "VM SA for ${var.name}"
}

resource "google_compute_instance" "vm" {
  name         = var.name
  zone         = var.zone
  machine_type = var.machine_type
  tags         = var.tags
  boot_disk { initialize_params { image = "debian-cloud/debian-12" } }
  network_interface {
    network    = var.network
    subnetwork = var.subnet
    # No external IP => private-only instance
  }
  service_account {
    email  = google_service_account.sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  metadata = { enable-oslogin = "TRUE" }
  shielded_instance_config { enable_secure_boot = true }
  metadata_startup_script = var.startup_script
}
