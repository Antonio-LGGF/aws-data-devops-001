variable "database_name" {
  type        = string
  description = "Name of the Glue database"
}

variable "tags" {
  type    = map(string)
  default = null
}