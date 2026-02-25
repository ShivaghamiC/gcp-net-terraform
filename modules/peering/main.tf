
resource "google_compute_network_peering" "a_to_b" {
  name                  = var.name_a_to_b
  network               = var.network_a
  peer_network          = var.network_b
  export_custom_routes  = true
  import_custom_routes  = true
}

resource "google_compute_network_peering" "b_to_a" {
  name                  = var.name_b_to_a
  network               = var.network_b
  peer_network          = var.network_a
  export_custom_routes  = true
  import_custom_routes  = true
}
