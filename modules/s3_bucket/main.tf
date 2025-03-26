resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_object" "raw_prefix" {
  bucket  = aws_s3_bucket.this.id
  key     = "raw/"
  content = ""
}

resource "aws_s3_object" "processed_prefix" {
  bucket  = aws_s3_bucket.this.id
  key     = "processed/"
  content = ""
}

# Enable EventBridge notifications for this bucket
resource "aws_s3_bucket_notification" "eventbridge" {
  bucket = aws_s3_bucket.this.id

  eventbridge = true

  depends_on = [aws_s3_bucket.this]
}

