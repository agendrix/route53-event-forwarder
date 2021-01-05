locals {
  lambda_zip   = "${path.module}/lambda.zip"
  event_source = "agendrix.route53-event-forwarder"
}

resource "aws_lambda_function" "lambda" {
  function_name    = "route53-event-forwarder"
  filename         = local.lambda_zip
  source_code_hash = filebase64sha256(local.lambda_zip)
  handler          = "index.handler"
  role             = aws_iam_role.lambda_execution_role.arn

  runtime = "nodejs12.x"

  environment {
    variables = {
      REGION       = var.region
      EVENT_SOURCE = local.event_source
    }
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 7
}

resource "aws_iam_role" "lambda_execution_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "allow_put_events" {
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "events:PutEvents"
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_permission" "allow_invocation_from_eventbridge" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.route53_events.arn
}

resource "aws_cloudwatch_event_rule" "route53_events" {
  name = "route53-events"

  event_pattern = jsonencode({
    source      = ["aws.route53"]
    detail-type = ["AWS API Call via CloudTrail"]
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.route53_events.name
  arn  = aws_lambda_function.lambda.arn
}

data "aws_region" "current" {}

resource "null_resource" "region_validation" {
  provisioner "local-exec" {
    command = "test $REGION = us-east-1"
    environment = {
      REGION = data.aws_region.current.name
    }
  }
}
