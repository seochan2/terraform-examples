locals {
  project_name = "tf-sample"
}

module "vpc" {
  source = "./modules/vpc"

  name   = local.project_name
  cidr   = "10.0.0.0/16"
  region = "ap-southeast-2"

  enable_dns_hostnames = true

  azs              = ["a", "c"]
  public_subnets   = ["10.0.10.0/24", "10.0.11.0/24"]
  private_subnets  = ["10.0.50.0/24", "10.0.51.0/24"]
  database_subnets = ["10.0.100.0/24", "10.0.101.0/24"]

  single_nat_gateway = terraform.workspace == "stg" ? true : false

  default_tags = {
    TerraformManaged = true
    Environment      = terraform.workspace
    Project          = local.project_name
  }
}
