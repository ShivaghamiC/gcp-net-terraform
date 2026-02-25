
variable "public_zone_name"   { type = string }
variable "public_zone_fqdn"   { type = string }
variable "private_zone_name"  { type = string }
variable "private_zone_fqdn"  { type = string }
variable "app_name"           { type = string }
variable "external_ip"        { type = string }
variable "network_self_link"  { type = string }
variable "private_records" { type = map(string) default = {} }
