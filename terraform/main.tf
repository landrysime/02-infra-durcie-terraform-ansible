# Projet 02 — Infra durcie as-code
# Architecture segmentée : DMZ (publique) + zone interne (privée) + filtrage par SG.

terraform {
  required_version = ">= 1.5"
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

# AMI Debian 12 (bookworm) officielle, la plus récente
data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"] # Debian officiel

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "vpc" {
  source            = "./modules/vpc"
  project           = var.project
  vpc_cidr          = var.vpc_cidr
  dmz_cidr          = var.dmz_subnet_cidr
  internal_cidr     = var.internal_subnet_cidr
  availability_zone = var.availability_zone
}

module "security_groups" {
  source            = "./modules/security_groups"
  project           = var.project
  vpc_id            = module.vpc.vpc_id
  admin_cidr        = var.admin_cidr
  internal_app_port = var.internal_app_port
}

# --- Serveur DMZ (public) ---
resource "aws_instance" "dmz" {
  ami                    = data.aws_ami.debian.id
  instance_type          = var.instance_type
  subnet_id              = module.vpc.dmz_subnet_id
  vpc_security_group_ids = [module.security_groups.dmz_sg_id]
  key_name               = var.key_name

  tags = {
    Name    = "${var.project}-dmz-server"
    Zone    = "dmz"
    Project = var.project
  }
}

# --- Serveur interne (privé) ---
resource "aws_instance" "internal" {
  ami                    = data.aws_ami.debian.id
  instance_type          = var.instance_type
  subnet_id              = module.vpc.internal_subnet_id
  vpc_security_group_ids = [module.security_groups.internal_sg_id]
  key_name               = var.key_name

  tags = {
    Name    = "${var.project}-internal-server"
    Zone    = "internal"
    Project = var.project
  }
}
