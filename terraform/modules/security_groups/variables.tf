variable "project" {
  description = "Préfixe de nommage des ressources"
  type        = string
  default     = "infra-durcie"
}

variable "vpc_id" {
  description = "ID du VPC où créer les security groups"
  type        = string
}

variable "admin_cidr" {
  description = "IP d'administration autorisée en SSH, en /32 (ex. 203.0.113.4/32). Jamais 0.0.0.0/0."
  type        = string

  validation {
    condition     = var.admin_cidr != "0.0.0.0/0"
    error_message = "admin_cidr ne doit jamais être 0.0.0.0/0 : limite le SSH à ton IP publique en /32."
  }
}

variable "internal_app_port" {
  description = "Port applicatif de la zone interne joignable depuis la DMZ"
  type        = number
  default     = 8080
}
