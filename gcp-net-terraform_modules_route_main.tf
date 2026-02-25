
resource "google_compute_route" "custom" {
  for_each                  = var.routes
  name                      = each.value.name
  network                   = var.network
  dest_range                = each.value.dest_cidr
  priority                  = 1000
  next_hop_instance         = lookup(each.value, "next_hop_instance", null)
  next_hop_instance_zone    = lookup(each.value, "next_hop_instance_zone", null)
  next_hop_gateway          = lookup(each.value, "next_hop_gateway", null)
}
