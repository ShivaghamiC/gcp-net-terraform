output "internal_ip" {
  value = google_compute_instance.vm.network_interface[0].network_ip 
}

output "sa_email" {
  value = google_service_account.sa.email 
}
