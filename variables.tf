variable "aws_region" {
  description = "AWS region to deploy in"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "env" {
  description = "Deployment environment"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
}
