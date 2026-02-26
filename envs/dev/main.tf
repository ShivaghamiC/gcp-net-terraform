
locals {
  vpc1_name = "vpc-app-dev"
  vpc2_name = "vpc-onprem-sim"
}

module "vpc1" {
  source = "../../modules/vpc"
  name   = local.vpc1_name
  delete_default_routes = true
  subnets = {
    a = { name = "sub-a", cidr = "10.10.1.0/24", region = var.region }
    b = { name = "sub-b", cidr = "10.10.2.0/24", region = var.region }
  }
}

module "vpc2" {
  source = "../../modules/vpc"
  name   = local.vpc2_name
  delete_default_routes = true
  subnets = {
    a = { name = "ops-a", cidr = "10.20.1.0/24", region = var.region }
  }
}

module "nat1" {
  source            = "../../modules/nat"
  name              = "app-dev"
  region            = var.region
  network           = module.vpc1.network_self_link
  subnet_self_links = values(module.vpc1.subnet_self_links)
}

module "fw" {
  source            = "../../modules/firewall"
  network_name      = module.vpc1.network_name
  ssh_target_sas    = [module.vm_a.sa_email]  # restrict SSH to VM SA via IAP
  web_target_tags   = ["web"]
  web_source_ranges = ["0.0.0.0/0"]
}

module "peer" {
  source      = "../../modules/peering"
  name_a_to_b = "app-to-onprem"
  name_b_to_a = "onprem-to-app"
  network_a   = module.vpc1.network_self_link
  network_b   = module.vpc2.network_self_link
}

module "vm_a" {
  source = "../../modules/compute_vm"
  name   = "vm-a"
  sa_id  = "vm-a-sa"
  zone   = "${var.region}-a"
  network = module.vpc1.network_self_link
  subnet  = module.vpc1.subnet_self_links["a"]
  tags    = ["web"]
  startup_script = "apt-get update -y && apt-get install -y nginx iperf3"
}

module "vm_b" {
  source = "../../modules/compute_vm"
  name   = "vm-b"
  sa_id  = "vm-b-sa"
  zone   = "${var.region}-b"
  network = module.vpc1.network_self_link
  subnet  = module.vpc1.subnet_self_links["b"]
  startup_script = "apt-get update -y && apt-get install -y iperf3"
}

module "ext_lb" {
  source  = "../../modules/lb_external_https"
  name    = "web-ext"
  region  = var.region
  network = module.vpc1.network_self_link
  subnet  = module.vpc1.subnet_self_links["a"]
  domain  = var.app_domain
}

module "ilb" {
  source      = "../../modules/lb_internal_tcp"
  name        = "web-ilb"
  region      = var.region
  network     = module.vpc1.network_self_link
  subnet      = module.vpc1.subnet_self_links["b"]
  backend_igm = module.ext_lb.mig_instance_group_self_link
}

module "dns" {
  source            = "../../modules/dns"
  public_zone_name  = "public-zone"
  public_zone_fqdn  = var.public_zone_fqdn
  private_zone_name = "internal-zone"
  private_zone_fqdn = "internal"
  app_name          = "app"
  external_ip       = module.ext_lb.lb_ip
  network_self_link = module.vpc1.network_self_link
  private_records   = {
    "vm-a" = module.vm_a.internal_ip,
    "vm-b" = module.vm_b.internal_ip
  }
}

# Variables for providers
variable "project_id"       { type = string }
variable "region"           { type = string }
variable "deploy_sa_email"  { type = string }
variable "public_zone_fqdn" { type = string }
variable "app_domain"       { type = string }

# Provider bridge
output "external_lb_ip" { value = module.ext_lb.lb_ip }
