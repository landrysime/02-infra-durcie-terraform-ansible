output "dmz_sg_id" {
  description = "ID du security group DMZ"
  value       = aws_security_group.dmz.id
}

output "internal_sg_id" {
  description = "ID du security group interne"
  value       = aws_security_group.internal.id
}
