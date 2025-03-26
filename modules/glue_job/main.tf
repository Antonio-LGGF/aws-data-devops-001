resource "aws_glue_job" "this" {
  name     = var.job_name
  role_arn = var.iam_role_arn

  command {
    name            = "glueetl"
    script_location = var.script_location
    python_version  = "3"
  }

  glue_version = "4.0"
  max_capacity = 2.0  # 2 DPU
}
