
variable "name"                     { type = string }
variable "region"                   { type = string }
variable "network"                  { type = string }
variable "peer_gateway_ip"          { type = string }
variable "shared_secret"            { type = string }
variable "local_asn"                { type = number }
variable "peer_asn"                 { type = number }
variable "bgp_interface_cidr_local" { type = string }
variable "bgp_interface_peer_ip"    { type = string }
