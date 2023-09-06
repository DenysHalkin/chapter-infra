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

    actions   = ["*"]
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