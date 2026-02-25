
variable "name"         { type = string }
variable "region"       { type = string }
variable "network"      { type = string }
variable "subnet"       { type = string }
variable "domain"       { type = string }
variable "machine_type" { type = string default = "e2-micro" }
