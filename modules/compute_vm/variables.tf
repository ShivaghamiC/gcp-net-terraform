variable "name" {
  type        = string
  description = "The name of the VM instance." [cite: 1]
}

variable "sa_id" {
  type        = string
  description = "The account ID for the service account." [cite: 1]
}

variable "zone" {
  type        = string
  default     = "us-central1-a" [cite: 1]
}

variable "machine_type" {
  type        = string
  default     = "e2-micro" [cite: 1]
}

variable "network" {
  type        = string
  description = "The VPC network name." [cite: 1]
}

variable "subnet" {
  type        = string
  description = "The subnetwork name." [cite: 1]
}

variable "tags" {
  type        = list(string)
  default     = [] [cite: 1]
}

variable "startup_script" {
  type        = string
  default     = "" 
}
