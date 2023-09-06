resource "aws_iam_group" "service_accounts" {
  name = "chapter-service-accounts"
}

resource "aws_iam_user" "frontend_deploy_service" {
  name          = "chapter-frontend-deploy-service"
  force_destroy = true
}

resource "aws_iam_access_key" "frontend_deploy_service" {
  user = aws_iam_user.frontend_deploy_service.name
}

resource "aws_iam_group_membership" "service_accounts" {
  name  = "chapter-service-accounts-membership"
  group = aws_iam_group.service_accounts.name

  users = [
    aws_iam_user.frontend_deploy_service.name
  ]
}

data "aws_iam_policy_document" "frontend_deploy_service" {

  statement {
    sid    = "AllowDeployToS3"
    effect = "Allow"

    actions = [
      "s3:CopyObject",
      "s3:DeleteObject",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",

    ]
    resources = [
      "arn:aws:s3:::test-781931727887/*",
      "arn:aws:s3:::test-781931727887"
    ]
  }
}

resource "aws_iam_policy" "frontend_deploy_service" {
  name        = "chapter-frontend-deploy-service-policy"
  description = "Policy allows to deploy web app to S3"
  policy      = data.aws_iam_policy_document.frontend_deploy_service.json
}

resource "aws_iam_user_policy_attachment" "frontend_deploy_service" {
  user       = aws_iam_user.frontend_deploy_service.name
  policy_arn = aws_iam_policy.frontend_deploy_service.arn
}


