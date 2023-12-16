---
title: "Terraform AWS CloudFront Static site and S3 bucket"
date: 2021-06-28T11:35:55+01:00
draft: false
---

# Creating a CloudFront + S3 static site in Terraform

Creating a simple static site using serverless computing. This was a project which would lend itself to Hugo, S3 and/or CloudFront. The site used https://gohugo.io/ to generate the content, the github repo for the project is https://github.com/tommybobbins/chapel_ramblers_static_site. Alex covers this step by step in his blog here: https://www.alexhyett.com/terraform-s3-static-website-hosting/

To upload content additions that can be used is the local-exec to copy the site content in place from var.site_content (hugo public directory) to the destination s3 bucket:

```
# Upload content
resource "null_resource" "remove_and_upload_to_s3" {
  provisioner "local-exec" {
    command = "aws s3 sync --metadata-directive REPLACE --cache-control 'max-age=86400, public' ${var.site_content} s3://${aws_s3_bucket.www_bucket.id}"
  }
}
```

The cache control is set to 86400 seconds here. The github repo for this is https://github.com/tommybobbins/chapel_ramblers_static_site.
