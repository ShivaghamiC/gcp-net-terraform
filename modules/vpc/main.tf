
resource "google_compute_network" "vpc" {
  name                            = var.name
  auto_create_subnetworks         = false
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = var.delete_default_routes
}

resource "google_compute_subnetwork" "subs" {
  for_each                 = var.subnets
  name                     = each.value.name
  ip_cidr_range            = each.value.cidr
  region                   = each.value.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
  log_config {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
