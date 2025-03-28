resource "aws_iam_user" "s3_write_access" {
  name = "${split(".",var.domain_name)[0]}-bucket-write-role"
}

data "aws_iam_policy_document" "s3_write_access" {
  statement {
    sid    = "AllowS3RWScript"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListObjectsV2",
      "s3:ListBucket",
      "s3:CopyObject",
      "s3:DeleteObject"
    ]
    resources = [aws_s3_bucket.www.arn,"${aws_s3_bucket.www.arn}/*"]
  }
}

resource "aws_iam_policy" "s3_write_access" {
  name   = "AllowWriteBucket-${split(".",var.domain_name)[0]}"
  path   = "/"
  policy = data.aws_iam_policy_document.s3_write_access.json
}

resource "aws_iam_user_policy_attachment" "s3_write_access" {
  user       = aws_iam_user.s3_write_access.name
  policy_arn = aws_iam_policy.s3_write_access.arn
}

locals {

github_name = replace("github-oidc-${var.domain_name}",".","-")

}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

module "github-oidc" {
 oidc_provider_arn = length(data.aws_iam_openid_connect_provider.github.arn) >= 1 ? data.aws_iam_openid_connect_provider.github.arn : null
 source  = "terraform-module/github-oidc-provider/aws"
 version = "~> 1"
 role_name = local.github_name
 create_oidc_provider = length(data.aws_iam_openid_connect_provider.github.arn) >= 1 ? false : true
 create_oidc_role     = true

 repositories              = [var.github_repository]
 oidc_role_attach_policies = [aws_iam_policy.s3_write_access.arn]
#  oidc_role_attach_policies = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]
}


# This is a test
