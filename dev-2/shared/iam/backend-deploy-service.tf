resource "aws_iam_group" "backend_deploy_service" {
  name = "backend-deploy-service"
}

resource "aws_iam_user" "backend_deploy_service" {
  name          = "chapter-backend-deploy-service"
  force_destroy = true
}

resource "aws_iam_access_key" "backend_deploy_service" {
  user = aws_iam_user.backend_deploy_service.name
}

resource "aws_iam_group_membership" "backend_service_accounts" {
  name  = "chapter-backend-service-accounts-membership"
  group = aws_iam_group.backend_deploy_service.name

  users = [
    aws_iam_user.backend_deploy_service.name
  ]
}

data "aws_iam_policy_document" "backend_deploy_service" {

  statement {
    sid    = "AllowECR"
    effect = "Allow"

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:BatchGetImage",
      "ecr:Describe*",
      "ecr:GetAuthorizationToken",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages"
    ]
    resources = ["*"]
  }
}


resource "aws_iam_policy" "backend_deploy_service" {
  name        = "chapter-backend-deploy-service-policy"
  description = "Policy allows to deploy web app to S3"
  policy      = data.aws_iam_policy_document.backend_deploy_service.json
}

resource "aws_iam_group_policy_attachment" "backend_deploy_service" {
  policy_arn = aws_iam_policy.backend_deploy_service.arn
  group      = aws_iam_group.backend_deploy_service.name
}


