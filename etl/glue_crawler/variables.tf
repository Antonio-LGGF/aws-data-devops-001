variable "crawler_name" {
  type = string
}

variable "iam_role_arn" {
  type = string
}

variable "database_name" {
  type = string
}

variable "s3_target_path" {
  type = string
}

variable "schedule" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = null
}

