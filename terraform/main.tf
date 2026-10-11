# Projet 02 — Infra durcie as-code
# Architecture segmentée : DMZ (publique) + zone interne (privée) + pare-feu
# TODO Jour 2 : brancher les modules vpc et security_groups, 2 instances EC2.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# module "vpc" {
#   source       = "./modules/vpc"
#   vpc_cidr     = var.vpc_cidr
#   dmz_cidr     = var.dmz_subnet_cidr
#   internal_cidr = var.internal_subnet_cidr
# }

# module "security_groups" {
#   source      = "./modules/security_groups"
#   vpc_id      = module.vpc.vpc_id
#   admin_ip    = var.admin_ip
# }
