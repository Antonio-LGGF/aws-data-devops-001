resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_object" "raw_prefix" {
  bucket  = aws_s3_bucket.this.id
  key     = "raw/"
  content = ""
  tags    = var.tags
}

resource "aws_s3_object" "processed_prefix" {
  bucket  = aws_s3_bucket.this.id
  key     = "processed/"
  content = ""
  tags    = var.tags
}

# Enable EventBridge notifications for this bucket
resource "aws_s3_bucket_notification" "eventbridge" {
  bucket = aws_s3_bucket.this.id

  eventbridge = true

  depends_on = [aws_s3_bucket.this]
}

