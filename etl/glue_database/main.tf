resource "aws_glue_catalog_database" "this" {
  name = var.database_name
  tags = var.tags
}
