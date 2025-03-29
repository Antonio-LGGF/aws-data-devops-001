variable "role_name" {
  type        = string
  description = "Name of the IAM role for Glue"
}

variable "tags" {
  type    = map(string)
  default = null
}