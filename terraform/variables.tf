variable "aws_region" {
  description = "Region AWS"
  type        = string
  default     = "eu-west-3"
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "projet02-infra"
}

variable "environment" {
  description = "Environnement"
  type        = string
  default     = "dev"
}
