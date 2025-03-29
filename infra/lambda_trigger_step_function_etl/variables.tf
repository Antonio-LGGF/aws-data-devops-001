variable "lambda_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "state_machine_arn" {
  description = "The ARN of the Step Function State Machine"
  type        = string
}

variable "lambda_zip_file" {
  description = "Path to the Lambda zip file"
  type        = string
}

variable "lambda_execution_role_arn" {
  description = "IAM Role ARN for Lambda to assume"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = null
}
