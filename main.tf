terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.40.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

#===============

module "network" {
  source = "./modules/network"

  availability_zones = var.availability_zones
  cidr_block         = var.cidr_block
  tgw_asn            = var.tgw_asn
}

#===============

module "security" {
  source = "./modules/security"

  vpc_id_prod   = module.network.vpc_id_prod
  vpc_id_test   = module.network.vpc_id_test
  vpc_id_egress = module.network.vpc_id_egress
  vpc_id_onprem = module.network.vpc_id_onprem
  sg_cidr       = var.sg_cidr

  depends_on = [
    module.network
  ]
}

#===============

module "instances" {
  source = "./modules/instances"

  sg_id_prod   = module.security.sg_id_prod
  sg_id_test   = module.security.sg_id_test
  sg_id_egress = module.security.sg_id_egress
  sg_id_onprem = module.security.sg_id_onprem

  prod_sub   = module.network.prod_sub
  onprem_sub = module.network.onprem_sub
  test_sub   = module.network.test_sub

  key_name      = var.key_name
  instance_type = var.instance_type
  ami           = var.ami

  depends_on = [
    module.security
  ]
}