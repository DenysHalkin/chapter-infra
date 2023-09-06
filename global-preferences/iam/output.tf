output "frontend_deploy_service_access_key" {
  value = {
    access_key_id     = aws_iam_access_key.frontend_deploy_service.id
    secret_access_key = aws_iam_access_key.frontend_deploy_service.secret
  }

  sensitive = true
}