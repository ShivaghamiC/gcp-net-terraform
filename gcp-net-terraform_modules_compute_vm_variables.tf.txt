
variable "name"          { type = string }
variable "sa_id"         { type = string }
variable "zone"          { type = string }
variable "machine_type"  { type = string default = "e2-micro" }
variable "network"       { type = string }
variable "subnet"        { type = string }
variable "tags"          { type = list(string) default = [] }
variable "startup_script"{ type = string default = "" }
