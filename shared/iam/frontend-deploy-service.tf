resource "aws_iam_group" "frontend_deploy_service" {
  name = "frontend-deploy-service"
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
  group = aws_iam_group.frontend_deploy_service.name

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
      "arn:aws:s3:::chapter-dev-frontend-web-app-usw2",
    ]
  }

  statement {
    sid    = "AllowToGetKMS"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncryptFrom",
      "kms:ReEncryptTo",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyPair",
      "kms:GenerateDataKeyPairWithoutPlaintext",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:DescribeKey"
    ]
    resources = ["arn:aws:kms:us-west-2:781931727887:key/77a3def6-1afa-4b0f-8e54-c2c95935c7cd"]
  }
}

resource "aws_iam_policy" "frontend_deploy_service" {
  name        = "chapter-frontend-deploy-service-policy"
  description = "Policy allows to deploy web app to S3"
  policy      = data.aws_iam_policy_document.frontend_deploy_service.json
}

resource "aws_iam_group_policy_attachment" "frontend_deploy_service" {
  policy_arn = aws_iam_policy.frontend_deploy_service.arn
  group      = aws_iam_group.frontend_deploy_service.name
}


