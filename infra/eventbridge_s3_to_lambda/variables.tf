variable "rule_name" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "lambda_name" {
  type = string
}

variable "lambda_arn" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = null
}