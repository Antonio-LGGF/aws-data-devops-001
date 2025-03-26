provider "aws" {
  region = "us-east-1"
}

###################
module "s3_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = "my-data-lake-demo-bucket" # change if needed
}

output "bucket_name" {
  value = module.s3_bucket.bucket_name
}


#######################
module "glue_database" {
  source        = "./modules/glue_database"
  database_name = "data_lake_db"
}

output "glue_database_name" {
  value = module.glue_database.name
}

#######################
module "glue_iam_role" {
  source    = "./modules/glue_iam_role"
  role_name = "glue-crawler-role"
}

output "glue_iam_role_arn" {
  value = module.glue_iam_role.arn
}

######################
module "glue_crawler" {
  source         = "./modules/glue_crawler"
  crawler_name   = "processed-data-crawler"
  iam_role_arn   = module.glue_iam_role.arn #crawler role
  database_name  = module.glue_database.name
  s3_target_path = "s3://${module.s3_bucket.bucket_name}/processed/"
  schedule       = null # or use cron if you want it scheduled
}

output "glue_crawler_name" {
  value = module.glue_crawler.crawler_name
}

#######################################
resource "aws_s3_object" "glue_script" {
  bucket = module.s3_bucket.bucket_name
  key    = "scripts/process_raw_to_parquet.py"
  source = "${path.module}/scripts/process_raw_to_parquet.py"
  etag   = filemd5("${path.module}/scripts/process_raw_to_parquet.py")
}

module "glue_job" {
  source          = "./modules/glue_job"
  job_name        = "process-raw-to-parquet"
  iam_role_arn    = module.glue_iam_role.arn
  script_location = "s3://${module.s3_bucket.bucket_name}/scripts/process_raw_to_parquet.py"

}

output "glue_job_name" {
  value = module.glue_job.job_name
}

#################################
module "step_function_etl" {
  source              = "./modules/step_function_etl"
  name                = "etl-orchestration"
  crawler_name        = module.glue_crawler.crawler_name
  glue_job_name       = module.glue_job.job_name
  role_arn            = module.step_function_etl.role_arn
  s3_target_path_base = "s3://${module.s3_bucket.bucket_name}/processed/"
}

output "crawler_name" {
  value = module.step_function_etl.crawler_name
}

#################################
module "lambda_trigger_step_function_etl" {
  source                    = "./modules/lambda_trigger_step_function_etl"
  lambda_name               = "trigger-step-function-etl"
  state_machine_arn         = module.step_function_etl.state_machine_arn
  lambda_zip_file           = "./modules/lambda_trigger_step_function_etl/lambda_trigger_step_function_etl.zip" # Path to the zip file
  lambda_execution_role_arn = module.step_function_etl.role_arn
}

output "lambda_name" {
  value = module.lambda_trigger_step_function_etl.lambda_name
}

output "lambda_arn" {
  value = module.lambda_trigger_step_function_etl.lambda_arn
}

############################
module "eventbridge_trigger" {
  source      = "./modules/eventbridge_s3_to_lambda"
  rule_name   = "trigger-lambda-on-upload"
  bucket_name = module.s3_bucket.bucket_name
  lambda_name = module.lambda_trigger_step_function_etl.lambda_name
  lambda_arn  = module.lambda_trigger_step_function_etl.lambda_arn
}


