output "arn" {
  value = aws_sfn_state_machine.this.arn
}

output "role_arn" {
  value = aws_iam_role.this.arn
}

output "state_machine_arn" {
  value = aws_sfn_state_machine.this.arn
}

output "s3_target_path_base" {
  value = var.s3_target_path_base
}

output "crawler_name" {
  value = var.crawler_name
}
