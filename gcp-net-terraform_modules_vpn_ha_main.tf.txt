
resource "google_compute_ha_vpn_gateway" "gw" {
  name    = var.name
  network = var.network
  region  = var.region
}

resource "google_compute_external_vpn_gateway" "peer" {
  name            = "${var.name}-peer"
  redundancy_type = "SINGLE_IP_INTERNALLY_REDUNDANT"
  interface { id = 0 ip_address = var.peer_gateway_ip }
}

resource "google_compute_router" "cr" {
  name    = "${var.name}-cr"
  region  = var.region
  network = var.network
  bgp { asn = var.local_asn }
}

resource "google_compute_vpn_tunnel" "tunnel0" {
  name                            = "${var.name}-t0"
  region                          = var.region
  vpn_gateway                     = google_compute_ha_vpn_gateway.gw.id
  vpn_gateway_interface           = 0
  peer_external_gateway           = google_compute_external_vpn_gateway.peer.id
  peer_external_gateway_interface = 0
  shared_secret                   = var.shared_secret
  ike_version                     = 2
  router                          = google_compute_router.cr.name
}

resource "google_compute_router_interface" "int0" {
  name       = "${var.name}-int0"
  router     = google_compute_router.cr.name
  region     = var.region
  ip_range   = var.bgp_interface_cidr_local
  vpn_tunnel = google_compute_vpn_tunnel.tunnel0.name
}

resource "google_compute_router_peer" "peer0" {
  name            = "${var.name}-peer0"
  router          = google_compute_router.cr.name
  region          = var.region
  peer_asn        = var.peer_asn
  interface       = google_compute_router_interface.int0.name
  peer_ip_address = var.bgp_interface_peer_ip
  advertise_mode  = "DEFAULT"
}
