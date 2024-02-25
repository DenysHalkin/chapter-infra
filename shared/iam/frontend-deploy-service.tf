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

resource "aws_iam_group_membership" "frontend_service_accounts" {
  name  = "chapter-frontend-service-accounts-membership"
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
      "arn:aws:s3:::chapter-dev-frontend-web-app-euc1",
      "arn:aws:s3:::chapter-dev-frontend-web-app-euc1/*"
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
    resources = ["arn:aws:kms:eu-central-1:${data.aws_caller_identity.current.account_id}:key/586ded66-609d-4fae-9e7f-9541dced7de1"]
  }

  statement {
    sid    = "AllowCloudfrontInvalidation"
    effect = "Allow"

    actions = [
      "cloudfront:CreateInvalidation",
      "cloudfront:GetInvalidation"
    ]
    resources = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/E2UXNL30XT16LK"]
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


