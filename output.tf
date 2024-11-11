output "web-server-dns" {
  value = aws_alb.web-alb.dns_name
}
output "db_password" {
  value       = aws_secretsmanager_secret_version.password.secret_string
  sensitive   = false
  description = "The generated database password stored in AWS Secrets Manager"
}