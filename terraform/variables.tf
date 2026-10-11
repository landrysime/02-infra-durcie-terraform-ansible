variable "project" {
  description = "Préfixe de nommage des ressources"
  type        = string
  default     = "infra-durcie"
}

variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "eu-west-3"
}

variable "availability_zone" {
  description = "Zone de disponibilité"
  type        = string
  default     = "eu-west-3a"
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

variable "admin_cidr" {
  description = "IP publique autorisée en SSH, en /32 (ex. 203.0.113.4/32). Jamais 0.0.0.0/0."
  type        = string
}

variable "internal_app_port" {
  description = "Port applicatif de la zone interne joignable depuis la DMZ"
  type        = number
  default     = 8080
}

variable "instance_type" {
  description = "Type d'instance EC2 (Free Tier : t2.micro ou t3.micro selon la région)"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Nom de la paire de clés EC2 (créée/importée au préalable dans la région)"
  type        = string
}
