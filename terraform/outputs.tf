output "dmz_server_public_ip" {
  description = "IP publique du serveur DMZ (pour SSH et Ansible)"
  value       = aws_instance.dmz.public_ip
}

output "dmz_server_private_ip" {
  description = "IP privée du serveur DMZ"
  value       = aws_instance.dmz.private_ip
}

output "internal_server_private_ip" {
  description = "IP privée du serveur interne (joignable via rebond depuis la DMZ)"
  value       = aws_instance.internal.private_ip
}

output "vpc_id" {
  description = "ID du VPC créé"
  value       = module.vpc.vpc_id
}
