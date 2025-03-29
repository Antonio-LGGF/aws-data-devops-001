variable "role_name" {
  type        = string
  description = "Name of the IAM role for Glue"
}

variable "tags" {
  type    = map(string)
  default = null
}

variable "bucket_name" {
  description = "The name of the S3 bucket used for Glue jobs"
  type        = string
}
