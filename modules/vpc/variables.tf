
variable "name" { type = string }
variable "delete_default_routes" { 
  type = bool
  default = true 
}
variable "subnets" {
  type = map(object({
    name   = string
    cidr   = string
    region = string
  }))
}
