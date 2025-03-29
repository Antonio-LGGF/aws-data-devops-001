# Reference existing log group created automatically by Lambda
data "aws_cloudwatch_log_group" "lambda_logs" {
  name = "/aws/lambda/trigger-step-function-etl"
  tags = var.tags

}

# Alarm for Lambda function errors
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.lambda_name}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm when Lambda function has errors"
  tags                = var.tags
  dimensions = {
    FunctionName = var.lambda_name
  }
}

# Alarm for Step Function failures
resource "aws_cloudwatch_metric_alarm" "stepfunction_failures" {
  alarm_name          = "${var.step_function_name}-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ExecutionsFailed"
  namespace           = "AWS/States"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm when Step Function executions fail"
  tags                = var.tags
  dimensions = {
    StateMachineArn = var.step_function_arn
  }
}

# Alarm for Glue Job failures
resource "aws_cloudwatch_metric_alarm" "glue_job_failures" {
  alarm_name          = "${var.glue_job_name}-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FailedJobs"
  namespace           = "AWS/Glue"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm when Glue job fails"
  tags                = var.tags
  dimensions = {
    JobName = var.glue_job_name
  }
}
