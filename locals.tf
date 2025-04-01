locals {
  s3_bucket_name        = "${var.env}-data-lake-demo-bucket"
  s3_processed_path     = "s3://${local.s3_bucket_name}/processed/"
  glue_iam_role_name    = "${var.env}_glue_crawler_role"
  glue_database_name    = "${var.env}_data_lake_db"
  glue_crawler_name     = "${var.env}_processed_data_crawler"
  glue_job_name         = "${var.env}_process_raw_to_parquet"
  lambda_name           = "${var.env}_trigger_step_function_etl"
  eventbridge_rule_name = "${var.env}_trigger_lambda_on_upload"
  step_function_name    = "${var.env}_etl_orchestration"
}
