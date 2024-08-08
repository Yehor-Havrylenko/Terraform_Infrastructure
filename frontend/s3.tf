resource "aws_s3_bucket" "this" {
  for_each = var.s3_buckets

  bucket        = each.value.bucket_name
  force_destroy = each.value.force_destroy
}

resource "aws_s3_bucket_policy" "this" {
  for_each = var.s3_buckets

  bucket = aws_s3_bucket.this[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.this[each.key].iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.this[each.key].arn}/*"
      }
    ]
  })
}
