resource "aws_lambda_function" "this" {
  function_name = var.lambda_name
  tags          = var.tags

  # Replace with your Lambda code location
  filename         = var.lambda_zip_file
  source_code_hash = filebase64sha256(var.lambda_zip_file)
  runtime          = "python3.8"
  handler          = "main.lambda_handler"

  environment {
    variables = {
      STATE_MACHINE_ARN = var.state_machine_arn
    }
  }

  role = var.lambda_execution_role_arn
}