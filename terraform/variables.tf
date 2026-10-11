variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "eu-west-3"
}

variable "vpc_cidr" {
  description = "CIDR du VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "dmz_subnet_cidr" {
  description = "CIDR du sous-réseau DMZ (public)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "internal_subnet_cidr" {
  description = "CIDR du sous-réseau interne (privé)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "admin_ip" {
  description = "IP autorisée en SSH (ton IP publique /32) — JAMAIS 0.0.0.0/0"
  type        = string
}

variable "instance_type" {
  description = "Type d'instance EC2 (Free Tier)"
  type        = string
  default     = "t2.micro"
}
