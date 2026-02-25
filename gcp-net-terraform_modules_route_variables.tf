
variable "network" { type = string }
variable "routes" {
  type = map(object({
    name                  = string
    dest_cidr             = string
    next_hop_instance     = optional(string)
    next_hop_instance_zone = optional(string)
    next_hop_gateway      = optional(string)
  }))
}
