
variable "network_name"      { type = string }
variable "ssh_target_sas"    { 
  type = list(string) 
  default = [] 
}
variable "web_source_ranges" { 
  type = list(string) 
  default = ["0.0.0.0/0"] 
}
variable "web_target_tags"   { 
  type = list(string) 
  default = ["web"]
}
