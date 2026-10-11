output "vpc_id" {
  description = "ID du VPC"
  value       = aws_vpc.this.id
}

output "dmz_subnet_id" {
  description = "ID du sous-réseau DMZ (public)"
  value       = aws_subnet.dmz.id
}

output "internal_subnet_id" {
  description = "ID du sous-réseau interne (privé)"
  value       = aws_subnet.internal.id
}
