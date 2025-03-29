variable "lambda_name" {}
variable "step_function_name" {}
variable "step_function_arn" {}
variable "glue_job_name" {}
variable "tags" {
  type    = map(string)
  default = null
}
