resource "random_password" "master"{
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "password" {
  name = "test-db-password"
}

resource "aws_secretsmanager_secret_version" "password" {
  secret_id = aws_secretsmanager_secret.password.id
  secret_string = random_password.master.result

}

output "db_password" {
  value     = aws_secretsmanager_secret_version.password.secret_string
  sensitive = true
  description = "The generated database password stored in AWS Secrets Manager"
}