data "aws_iam_policy_document" "ui_bucket_policy" {
  statement {
    sid = "AllowPublicReadAccess"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${module.website.s3_bucket_arn}/*",
    ]
  }
}