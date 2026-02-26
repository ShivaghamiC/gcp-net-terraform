variable "name" {
  type        = string
  description = "The name of the VM instance."
}

variable "sa_id" {
  type        = string
  description = "The account ID for the service account."
}

variable "zone" {
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  type        = string
  default     = "e2-micro"
}

variable "network" {
  type        = string
  description = "The VPC network name."
}

variable "subnet" {
  type        = string
  description = "The subnetwork name."
}

variable "tags" {
  type        = list(string)
  default     = []
}

variable "startup_script" {
  type        = string
  default     = "" 
}
