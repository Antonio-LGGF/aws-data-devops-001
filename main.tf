provider "aws" {
  region = var.aws_region
}

#####################################
# Infrastructure Layer (infra/)
#####################################

module "s3_bucket" {
  source      = "./infra/s3_bucket"
  bucket_name = local.s3_bucket_name
  tags        = var.tags
}

output "bucket_name" {
  value = module.s3_bucket.bucket_name
}

module "glue_iam_role" {
  source      = "./infra/glue_iam_role"
  role_name   = local.glue_iam_role_name
  bucket_name = module.s3_bucket.bucket_name
}

output "glue_iam_role_arn" {
  value = module.glue_iam_role.arn
}

module "lambda_trigger_step_function_etl" {
  source                    = "./infra/lambda_trigger_step_function_etl"
  lambda_name               = local.lambda_name
  state_machine_arn         = module.step_function_etl.state_machine_arn
  lambda_zip_file           = "./infra/lambda_trigger_step_function_etl/lambda_trigger_step_function_etl.zip"
  lambda_execution_role_arn = module.step_function_etl.role_arn
  tags                      = var.tags
}

output "lambda_name" {
  value = module.lambda_trigger_step_function_etl.lambda_name
}

output "lambda_arn" {
  value = module.lambda_trigger_step_function_etl.lambda_arn
}

module "eventbridge_trigger" {
  source      = "./infra/eventbridge_s3_to_lambda"
  rule_name   = local.eventbridge_rule_name
  bucket_name = module.s3_bucket.bucket_name
  lambda_name = module.lambda_trigger_step_function_etl.lambda_name
  lambda_arn  = module.lambda_trigger_step_function_etl.lambda_arn
  tags        = var.tags
}

#####################################
# ETL Layer (etl/)
#####################################

module "glue_database" {
  source        = "./etl/glue_database"
  database_name = local.glue_database_name
  tags          = var.tags
}

output "glue_database_name" {
  value = module.glue_database.name
}

module "glue_crawler" {
  source         = "./etl/glue_crawler"
  crawler_name   = local.glue_crawler_name
  iam_role_arn   = module.glue_iam_role.arn
  database_name  = module.glue_database.name
  s3_target_path = local.s3_processed_path
  schedule       = null
  depends_on     = [module.s3_bucket] # Ensures prefix exists before crawler creation
  tags           = var.tags
}

output "glue_crawler_name" {
  value = module.glue_crawler.crawler_name
}

resource "aws_s3_object" "glue_script" {
  bucket = module.s3_bucket.bucket_name
  key    = "scripts/process_raw_to_parquet.py"
  source = "${path.module}/scripts/process_raw_to_parquet.py"
  etag   = filemd5("${path.module}/scripts/process_raw_to_parquet.py")
  tags   = var.tags
}

module "glue_job" {
  source          = "./etl/glue_job"
  job_name        = local.glue_job_name
  iam_role_arn    = module.glue_iam_role.arn
  script_location = "s3://${module.s3_bucket.bucket_name}/scripts/process_raw_to_parquet.py"
  tags            = var.tags
}

output "glue_job_name" {
  value = module.glue_job.job_name
}

#####################################
# Orchestration Layer (orchestration/)
#####################################

module "step_function_etl" {
  source              = "./orchestration/step_function_etl"
  name                = local.step_function_name
  crawler_name        = module.glue_crawler.crawler_name
  glue_job_name       = module.glue_job.job_name
  role_arn            = module.step_function_etl.role_arn
  s3_target_path_base = local.s3_processed_path
  tags                = var.tags
}

output "crawler_name" {
  value = module.step_function_etl.crawler_name
}

#####################################
# Monitoring Layer (monitoring/)
#####################################

module "monitoring" {
  source             = "./monitoring"
  lambda_name        = module.lambda_trigger_step_function_etl.lambda_name
  step_function_name = module.step_function_etl.name
  step_function_arn  = module.step_function_etl.state_machine_arn
  glue_job_name      = module.glue_job.job_name
  tags               = var.tags
}
