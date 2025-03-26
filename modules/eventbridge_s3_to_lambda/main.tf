# EventBridge rule: triggers on S3 "Object Created" in raw/ folder
resource "aws_cloudwatch_event_rule" "s3_event_to_lambda" {
  name        = var.rule_name
  description = "Trigger Lambda when a file is uploaded under raw/"

  event_pattern = jsonencode({
    "source": ["aws.s3"],
    "detail-type": ["Object Created"],
    "detail": {
      "bucket": {
        "name": [var.bucket_name]
      },
      "object": {
        "key": [{
          "prefix": "raw/"
        }]
      }
    }
  })
}

# Target: call the Lambda when rule is matched
resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule      = aws_cloudwatch_event_rule.s3_event_to_lambda.name
  target_id = "triggerLambda"
  arn       = var.lambda_arn
}

# Permission: allow EventBridge to invoke the Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_event_to_lambda.arn
}
