resource "aws_glue_crawler" "this" {
  name          = var.crawler_name
  role          = var.iam_role_arn
  database_name = var.database_name

  s3_target {
    path = var.s3_target_path  # s3://my-data-lake-demo-bucket/processed/
  }

  schedule = var.schedule
}
