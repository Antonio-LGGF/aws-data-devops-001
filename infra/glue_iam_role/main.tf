resource "aws_iam_role" "this" {
  name = var.role_name
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "glue.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach AWS-managed Glue policy
resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Inline policy for S3 access
resource "aws_iam_role_policy" "s3_access" {
  name = "glue-s3-access"
  role = aws_iam_role.this.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ],
        Resource = [
          "arn:aws:s3:::my-data-lake-demo-bucket",
          "arn:aws:s3:::my-data-lake-demo-bucket/raw/*",
          "arn:aws:s3:::my-data-lake-demo-bucket/scripts/*",
          "arn:aws:s3:::my-data-lake-demo-bucket/processed/*"
        ]
      }
    ]
  })
}
