resource "aws_iam_group" "devops" {
  name = "chapter-devops"
}

resource "aws_iam_user" "devops_1" {
  name          = "chapter-devops-1"
  force_destroy = true
}

resource "aws_iam_group_membership" "devops" {
  name  = "devops"
  group = aws_iam_group.devops.name

  users = [
    aws_iam_user.devops_1.name
  ]
}

data "aws_iam_policy_document" "devops" {

  statement {
    sid    = "AllowAll"
    effect = "Allow"

    actions   = [
      "acm-pca:*",
      "execute-api:*",
      "support:*",
      "access-analyzer:*",
      "autoscaling:*",
      "batch:*",
      "acm:*",
      "cloudformation:*",
      "cloudfront:*",
      "cloudtrail:*",
      "cloudwatch:*",
      "events:*",
      "logs:*",
      "codebuild:*",
      "codecommit:*",
      "codedeploy:*",
      "codepipeline:*",
      "config:*",
      "dynamodb:*",
      "dax:*",
      "ec2:*",
      "ecr:*",
      "ecs:*",
      "elasticache:*",
      "es:*",
      "glacier:*",
      "guardduty:*",
      "health:*",
      "iam:*",
      "inspector:*",
      "kms:*",
      "lambda:*",
      "apigateway:*",
      "rds:*",
      "resource-groups:*",
      "tag:*",
      "route53:*",
      "route53domains:*",
      "s3:*",
      "sts:*",
      "ses:*",
      "shield:*",
      "ssm:*",
      "secretsmanager:*",
      "sdb:*",
      "sns:*",
      "sqs:*",
      "securityhub:*",
      "trustedadvisor:*",
      "waf:*",
      "waf-regional:*",
      "wam:*",
      "xray:*"
   ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "devops" {
  name        = "chapter-devops-policy"
  description = "Policy allows administrative access to all account resources"
  policy      = data.aws_iam_policy_document.devops.json
}

resource "aws_iam_group_policy_attachment" "devops" {
  group      = aws_iam_group.devops.name
  policy_arn = aws_iam_policy.devops.arn
}