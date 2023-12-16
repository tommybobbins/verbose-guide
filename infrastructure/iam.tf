resource "aws_iam_user" "s3_write_access" {
  name = "bucket-write-role"
}

data "aws_iam_policy_document" "s3_write_access" {
  statement {
    sid    = "AllowS3RWScript"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:Put*"
    ]
    resources = [aws_s3_bucket.www.arn]
  }
}

resource "aws_iam_policy" "s3_write_access" {
  name   = "AllowWriteBucket"
  path   = "/"
  policy = data.aws_iam_policy_document.s3_write_access.json
}

resource "aws_iam_user_policy_attachment" "s3_write_access" {
  user       = aws_iam_user.s3_write_access.name
  policy_arn = aws_iam_policy.s3_write_access.arn
}


resource "aws_iam_access_key" "s3_write_access" {
  user = aws_iam_user.s3_write_access.name
}

resource "aws_secretsmanager_secret" "s3_write_access" {
  name        = "aws-credentials-s3-write-${var.domain_name}"
  description = "AWS Credentials to write to ${var.domain_name} bucket"
}


resource "aws_secretsmanager_secret_version" "s3_write_access" {
  secret_id     = aws_secretsmanager_secret.s3_write_access.id
  secret_string = <<EOF
    {
    "AWS_ACCESS_KEY_ID": "${aws_iam_access_key.s3_write_access.id}",
    "AWS_SECRET_ACCESS_KEY": "${aws_iam_access_key.s3_write_access.secret}"
    }
EOF
}

module "github-oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "~> 1"

  create_oidc_provider = true
  create_oidc_role     = true

  repositories              = [var.github_repository]
  oidc_role_attach_policies = [aws_iam_policy.s3_write_access.arn]
}
