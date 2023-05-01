# Only consume, never set secrets via terraform. Instead, set secrets via AWS Console.

data "aws_secretsmanager_secret" "service" {
  name = "${local.env}/service-${local.app_name}"
}

data "aws_secretsmanager_secret_version" "service" {
  secret_id = data.aws_secretsmanager_secret.service.id
}
