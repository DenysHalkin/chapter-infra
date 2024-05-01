locals {
  developers = [
  ]
}

resource "aws_iam_user" "developers" {
  count = length(local.developers)

  name          = local.developers[count.index]
  force_destroy = true
}

resource "aws_iam_group" "developers" {
  name = "chapter-developers"
}

resource "aws_iam_group_membership" "developers" {
  name  = "chapter-developers"
  group = aws_iam_group.developers.name

  users = aws_iam_user.developers[*].name
}

data "aws_iam_policy_document" "developers" {

  statement {
    sid    = "AllowUsersGetListIAMInfo"
    effect = "Allow"
    actions = [
      "iam:Get*",
      "iam:List*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowUsersToCreateEnableResyncDeleteTheirOwnVirtualMFADevice"
    effect = "Allow"
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice",
      "iam:DeleteVirtualMFADevice"
    ]

    resources = [
      "arn:aws:iam::*:mfa/$${aws:username}",
      "arn:aws:iam::*:user/$${aws:username}"
    ]
  }

  statement {
    sid    = "AllowUsersChangePasswordAndGenerateDeleteAccessKeysOfTheirOwnUser"
    effect = "Allow"
    actions = [
      "iam:*LoginProfile",
      "iam:*AccessKey*",
      "iam:*SSHPublicKey*"
    ]

    resources = [
      "arn:aws:iam::*:user/$${aws:username}"
    ]
  }

  statement {
    sid    = "AllowSSM"
    effect = "Allow"
    actions = [
      "ssm:Describe*",
      "ssm:Get*",
      "ssm:List*",
      "ssm:ResumeSession",
      "ssm:StartSession",
      "ssm:SendCommand",
      "ssm:TerminateSession"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "developers" {
  name        = "chapter-developers-policy"
  description = "Policy for devs"
  policy      = data.aws_iam_policy_document.developers.json
}

resource "aws_iam_group_policy_attachment" "developers" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.developers.arn
}

resource "aws_iam_group_policy_attachment" "read_only" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}