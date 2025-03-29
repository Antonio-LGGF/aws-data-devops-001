variable "name" {}
variable "role_arn" {}
variable "crawler_name" {}
variable "glue_job_name" {}

variable "s3_target_path_base" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = null
}