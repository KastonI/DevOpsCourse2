provider "aws" {
  region = var.aws_region
}


module "vpc" {
  source = "./modules/vpc"

  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  az_zone             = var.az_zone
}

module "routs_and_connections" {
  source              = "./modules/routs_and_connections"
  vpc                 = module.vpc.vpc
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  private_subnet_id   = module.vpc.private_subnet_id
  public_subnet_id    = module.vpc.public_subnet_id
}

module "ec2" {
  source = "./modules/ec2"

  ami_id            = var.ami_id
  key_name          = var.key_name
  instance_type     = var.instance_type
  private_instance  = var.private_instance
  public_instance   = var.public_instance
  private_subnet_id = module.vpc.private_subnet_id
  public_subnet_id  = module.vpc.public_subnet_id
  sg                = module.routs_and_connections.sg
}

terraform {
  backend "s3" {
    bucket  = "terraform-kast"
    key     = "terraform/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}