
resource "google_dns_managed_zone" "public" {
  name       = var.public_zone_name
  dns_name   = "${var.public_zone_fqdn}."
  visibility = "public"
}

resource "google_dns_record_set" "public_a" {
  name         = "${var.app_name}.${google_dns_managed_zone.public.dns_name}"
  type         = "A"
  ttl          = 60
  managed_zone = google_dns_managed_zone.public.name
  rrdatas      = [var.external_ip]
}

resource "google_dns_managed_zone" "private" {
  name       = var.private_zone_name
  dns_name   = "${var.private_zone_fqdn}."
  visibility = "private"
  private_visibility_config { networks { network_url = var.network_self_link } }
}

resource "google_dns_record_set" "vm_records" {
  for_each     = var.private_records
  name         = "${each.key}.${google_dns_managed_zone.private.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.private.name
  rrdatas      = [each.value]
}
