data "aws_arn" "course-table" {
  arn = "arn:aws:dynamodb:eu-central-1:763268634072:table/developer-course"
}

resource "aws_iam_role_policy" "save-course-lambda-policy" {
  name = "${var.name}-lambda-policy"
  role = aws_iam_role.save-course-lambda-role.id

  policy = jsonencode({
    Version = "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:*:*:*"
      },
      {
        "Effect" : "Allow",
        "Action" : "dynamodb:PutItem",
        "Resource" : data.aws_arn.course-table.id
    }]

  })
}

resource "aws_iam_role" "save-course-lambda-role" {
  name = "${var.name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Principal" : {
          "Service" : [
            "lambda.amazonaws.com"
          ]
        }
      },
    ]
  })
}


data "archive_file" "save-course-lambda" {
  type        = "zip"
  source_file = "${path.module}/${var.name}-lambda.js"
  output_path = "${path.module}/${var.name}-lambda.zip"
}

resource "aws_lambda_function" "save-course-lambda" {

  filename      = "${path.module}/${var.name}-lambda.zip"
  function_name = "${var.name}-lambda"
  role          = aws_iam_role.save-course-lambda-role.arn
  handler       = "${var.name}-lambda.handler"
  runtime = "nodejs12.x"
}

output "arn" {
  value = aws_lambda_function.save-course-lambda.invoke_arn
}

output "function_name" {
  value = aws_lambda_function.save-course-lambda.function_name
}