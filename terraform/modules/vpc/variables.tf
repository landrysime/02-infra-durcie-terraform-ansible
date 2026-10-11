variable "project" {
  description = "Préfixe de nommage des ressources"
  type        = string
  default     = "infra-durcie"
}

variable "vpc_cidr" {
  description = "CIDR du VPC"
  type        = string
}

variable "dmz_cidr" {
  description = "CIDR du sous-réseau DMZ (public)"
  type        = string
}

variable "internal_cidr" {
  description = "CIDR du sous-réseau interne (privé)"
  type        = string
}

variable "availability_zone" {
  description = "Zone de disponibilité des sous-réseaux"
  type        = string
}
