terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.40"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.40"
    }
  }
}

provider "google" {
  project       = "terraform-488518"
  region           = "asia-south1"
  impersonate_service_account  = "terraform-deployer@terraform-488518.iam.gserviceaccount.com"
}

provider "google-beta" {
  project                     = var.project_id
  region                      = var.region
  impersonate_service_account = var.deploy_sa_email
}

#variable "project_id" {
 # type        = string
  #description = "The GCP project ID"
  #default     = "terraform-488518"
#}

#variable "region" {
 # type        = string
  #default     = "asia-south1"
#}

#variable "deploy_sa_email" {
 # type        = string
  #description = "The email of the service account to impersonate"
  #default     = "terraform-deployer@terraform-488518.iam.gserviceaccount.com"
#}
