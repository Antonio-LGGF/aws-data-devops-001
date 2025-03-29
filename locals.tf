locals {
  aws_region            = "us-east-1"
  project_name          = "data_lake_demo"
  env                   = "dev" # Change as needed (e.g., dev, prod)
  s3_bucket_name        = "${local.env}-data-lake-demo-bucket"
  s3_processed_path     = "s3://${local.s3_bucket_name}/processed/"
  glue_iam_role_name    = "${local.env}_glue_crawler_role"
  glue_database_name    = "${local.env}_data_lake_db"
  glue_crawler_name     = "${local.env}_processed_data_crawler"
  glue_job_name         = "${local.env}_process_raw_to_parquet"
  lambda_name           = "${local.env}_trigger_step_function_etl"
  eventbridge_rule_name = "${local.env}_trigger_lambda_on_upload"
  step_function_name    = "${local.env}_etl_orchestration"
}

locals {
  tags = {
    Environment = "dev"
    Team        = "DataEngineering"
    Project     = "aws-data-devops-001"
    Owner       = "Antonio"
  }
}

