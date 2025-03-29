variable "job_name" {
  type = string
}

variable "iam_role_arn" {
  type = string
}

variable "script_location" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = null
}
