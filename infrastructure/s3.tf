####
resource "aws_s3_bucket" "www" {
  bucket = "www.${var.domain_name}"
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.www.bucket
  key    = "hello.txt"
  source = "hello.txt"
  etag   = filemd5("hello.txt")
}

resource "aws_s3_bucket_public_access_block" "www" {
  bucket = aws_s3_bucket.www.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "www" {
  name                              = "cloudfront OAC"
  description                       = "description of OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_iam_policy_document" "www" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.www.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.www_s3_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "www" {
  bucket = aws_s3_bucket.www.id
  policy = data.aws_iam_policy_document.www.json
}


####
# Add bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "www_encryption" {
  bucket = aws_s3_bucket.www.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_website_configuration" "www" {
  bucket = aws_s3_bucket.www.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_cors_configuration" "www_cors" {
  bucket = aws_s3_bucket.www.bucket

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["https://www.${var.domain_name}"]
    expose_headers  = ["ETag"]
  }
}

# S3 bucket for www.
resource "aws_s3_bucket_acl" "www" {
  bucket = aws_s3_bucket.www.id
  acl    = "public-read"
}
