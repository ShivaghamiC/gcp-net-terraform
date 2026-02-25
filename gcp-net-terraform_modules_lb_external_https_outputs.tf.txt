
output "lb_ip" { value = google_compute_global_forwarding_rule.fr.ip_address }
output "mig_instance_group_self_link" { value = google_compute_region_instance_group_manager.mig.instance_group }
