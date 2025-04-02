output "bucket_name" {
  value = module.s3_bucket.bucket_name
}

output "glue_iam_role_arn" {
  value = module.glue_iam_role.arn
}

output "lambda_name" {
  value = module.lambda_trigger_step_function_etl.lambda_name
}

output "lambda_arn" {
  value = module.lambda_trigger_step_function_etl.lambda_arn
}

output "glue_database_name" {
  value = module.glue_database.name
}

output "glue_crawler_name" {
  value = module.glue_crawler.crawler_name
}

output "glue_job_name" {
  value = module.glue_job.job_name
}

output "crawler_name" {
  value = module.step_function_etl.crawler_name
}