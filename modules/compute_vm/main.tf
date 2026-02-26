# Create the Service Account
resource "google_service_account" "sa" {
  account_id   = var.sa_id
  display_name = "VM SA for ${var.name}" 
}

# Create the Private Compute Instance
resource "google_compute_instance" "vm" {
  name         = var.name
  zone         = var.zone
  machine_type = var.machine_type
  tags         = var.tags 

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12" 
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnet
    # By omitting access_config, the VM gets no external IP 
  }

  service_account {
    email  = google_service_account.sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"] [cite: 4]
  }

  metadata = {
    enable-oslogin = "TRUE" [cite: 4]
  }

  shielded_instance_config {
    enable_secure_boot = true [cite: 4]
  }

  metadata_startup_script = var.startup_script [cite: 4]
}
