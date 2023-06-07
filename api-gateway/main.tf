data "aws_caller_identity" "this" {}

resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.names[0]}-api"
  description = "Created for educational purspose"
  endpoint_configuration {
    types = ["EDGE"]
  }
}

resource "aws_api_gateway_resource" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id               //rest_api_id - (Required) ID of the associated REST API and id - ID of the REST API
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id //root_resource_id - Resource ID of the REST API's root
  path_part   = var.names[0]
}


///// cors1

resource "aws_api_gateway_method" "cors" {
  api_key_required = false
  authorization    = "NONE"
  http_method      = "OPTIONS"
  resource_id      = aws_api_gateway_resource.this.id
  rest_api_id      = aws_api_gateway_rest_api.this.id
}

resource "aws_api_gateway_integration" "cors" {
  http_method = "OPTIONS"
  resource_id = aws_api_gateway_resource.this.id
  rest_api_id = aws_api_gateway_rest_api.this.id
  type        = "MOCK"
  //everything up is required
  connection_type  = "INTERNET"
  content_handling = "CONVERT_TO_TEXT"

  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  timeout_milliseconds = 29000

  depends_on = [
    aws_api_gateway_method.cors
  ]
}

resource "aws_api_gateway_method_response" "cors" {
  http_method = "OPTIONS"
  resource_id = aws_api_gateway_resource.this.id
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false
    "method.response.header.Access-Control-Allow-Methods" = false
    "method.response.header.Access-Control-Allow-Origin"  = false
    "method.response.header.Access-Control-Max-Age"       = true
  }
  rest_api_id = aws_api_gateway_rest_api.this.id
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.cors
  ]
}

resource "aws_api_gateway_integration_response" "cors1" {
  http_method = "OPTIONS"
  resource_id = aws_api_gateway_resource.this.id
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Authorization,Content-Type,X-Amz-Date,X-Amz-Security-Token,X-Api-Key'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,HEAD,GET,POST,PUT,PATCH,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Max-Age"       = "'7200'"
  }
  rest_api_id = aws_api_gateway_rest_api.this.id
  status_code = "200"

  depends_on = [
    aws_api_gateway_method_response.cors
  ]
}

//


# // save-course

resource "aws_api_gateway_method" "this" {
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.this.id //resource_id - (Required) API resource ID
  rest_api_id   = aws_api_gateway_rest_api.this.id //rest_api_id - (Required) ID of the associated REST API
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.this.id
  http_method             = aws_api_gateway_method.this.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = var.arns[0]

  depends_on = [
    aws_api_gateway_method.this
  ]
}


resource "aws_api_gateway_integration_response" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this.http_method
  status_code = aws_api_gateway_method_response.this.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_method_response" "this" {
  rest_api_id     = aws_api_gateway_rest_api.this.id
  resource_id     = aws_api_gateway_resource.this.id
  http_method     = aws_api_gateway_method.this.http_method
  status_code     = "200"
  response_models = { "application/json" = "Empty" }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_model" "this" {
  rest_api_id  = aws_api_gateway_rest_api.this.id
  name         = "save${var.names[1]}"
  description  = "a JSON schema"
  content_type = "application/json"

  schema = file("${path.module}/models-in-json/save-course-model.json")
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowExecutionFromAPIGatewayForSave${title(var.names[1])}"
  action        = "lambda:InvokeFunction"
  function_name = var.function_names[0]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:eu-central-1:${data.aws_caller_identity.this.account_id}:${aws_api_gateway_rest_api.this.id}/*/${aws_api_gateway_method.this.http_method}${aws_api_gateway_resource.this.path}"
}

//update-course

resource "aws_api_gateway_resource" "this2" {
  rest_api_id = aws_api_gateway_rest_api.this.id //rest_api_id - (Required) ID of the associated REST API and id - ID of the REST API
  parent_id   = aws_api_gateway_resource.this.id //root_resource_id - Resource ID of the REST API's root
  path_part   = "{id}"
}

///// cors2

resource "aws_api_gateway_method" "cors2" {
  api_key_required = false
  authorization    = "NONE"
  http_method      = "OPTIONS"
  resource_id      = aws_api_gateway_resource.this2.id
  rest_api_id      = aws_api_gateway_rest_api.this.id
}

resource "aws_api_gateway_integration" "cors2" {
  http_method = "OPTIONS"
  resource_id = aws_api_gateway_resource.this2.id
  rest_api_id = aws_api_gateway_rest_api.this.id
  type        = "MOCK"
  //everything up is required
  connection_type  = "INTERNET"
  content_handling = "CONVERT_TO_TEXT"

  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  timeout_milliseconds = 29000

  depends_on = [
    aws_api_gateway_method.cors2
  ]
}

resource "aws_api_gateway_method_response" "cors2" {
  http_method = "OPTIONS"
  resource_id = aws_api_gateway_resource.this2.id
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false
    "method.response.header.Access-Control-Allow-Methods" = false
    "method.response.header.Access-Control-Allow-Origin"  = false
    "method.response.header.Access-Control-Max-Age"       = true
  }
  rest_api_id = aws_api_gateway_rest_api.this.id
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.cors2
  ]
}

resource "aws_api_gateway_integration_response" "cors2" {
  http_method = "OPTIONS"
  resource_id = aws_api_gateway_resource.this2.id
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Authorization,Content-Type,X-Amz-Date,X-Amz-Security-Token,X-Api-Key'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,HEAD,GET,POST,PUT,PATCH,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Max-Age"       = "'7200'"
  }
  rest_api_id = aws_api_gateway_rest_api.this.id
  status_code = "200"

  depends_on = [
    aws_api_gateway_method_response.cors2
  ]
}

//

resource "aws_api_gateway_method" "this2" {
  http_method   = "PUT"
  resource_id   = aws_api_gateway_resource.this2.id //resource_id - (Required) API resource ID
  rest_api_id   = aws_api_gateway_rest_api.this.id  //rest_api_id - (Required) ID of the associated REST API
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "this2" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.this2.id
  http_method             = aws_api_gateway_method.this2.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = var.arns[1]
  passthrough_behavior    = "WHEN_NO_TEMPLATES"

  request_templates = {
    "application/json" = file("${path.module}/models-in-json/update-course-model.json")
  }

  depends_on = [
    aws_api_gateway_method.this2
  ]
}

resource "aws_api_gateway_integration_response" "this2" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this2.id
  http_method = aws_api_gateway_method.this2.http_method
  status_code = aws_api_gateway_method_response.this2.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_method_response" "this2" {
  rest_api_id     = aws_api_gateway_rest_api.this.id
  resource_id     = aws_api_gateway_resource.this2.id
  http_method     = aws_api_gateway_method.this2.http_method
  status_code     = "200"
  response_models = { "application/json" = "Empty" }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_lambda_permission" "this2" {
  statement_id  = "AllowExecutionFromAPIGatewayForUpdate${title(var.names[1])}"
  action        = "lambda:InvokeFunction"
  function_name = var.function_names[1]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:eu-central-1:${data.aws_caller_identity.this.account_id}:${aws_api_gateway_rest_api.this.id}/*/${aws_api_gateway_method.this2.http_method}${aws_api_gateway_resource.this.path}/*"
}


# //get-course

resource "aws_api_gateway_method" "this3" {
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.this2.id //resource_id - (Required) API resource ID
  rest_api_id   = aws_api_gateway_rest_api.this.id  //rest_api_id - (Required) ID of the associated REST API
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "this3" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.this2.id
  http_method             = aws_api_gateway_method.this3.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = var.arns[2]
  passthrough_behavior    = "WHEN_NO_TEMPLATES"

  request_templates = {
    "application/json" = file("${path.module}/models-in-json/get-course-model.json")
  }

  depends_on = [
    aws_api_gateway_method.this3
  ]
}

resource "aws_api_gateway_integration_response" "this3" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this2.id
  http_method = aws_api_gateway_method.this3.http_method
  status_code = aws_api_gateway_method_response.this3.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

}

resource "aws_api_gateway_method_response" "this3" {
  rest_api_id     = aws_api_gateway_rest_api.this.id
  resource_id     = aws_api_gateway_resource.this2.id
  http_method     = aws_api_gateway_method.this3.http_method
  status_code     = "200"
  response_models = { "application/json" = "Empty" }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_lambda_permission" "this3" {
  statement_id  = "AllowExecutionFromAPIGatewayForUpdate${title(var.names[1])}"
  action        = "lambda:InvokeFunction"
  function_name = var.function_names[2]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:eu-central-1:${data.aws_caller_identity.this.account_id}:${aws_api_gateway_rest_api.this.id}/*/${aws_api_gateway_method.this3.http_method}${aws_api_gateway_resource.this.path}/*"
}

//delete-course

resource "aws_api_gateway_method" "this4" {
  http_method   = "DELETE"
  resource_id   = aws_api_gateway_resource.this2.id //resource_id - (Required) API resource ID
  rest_api_id   = aws_api_gateway_rest_api.this.id  //rest_api_id - (Required) ID of the associated REST API
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "this4" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.this2.id
  http_method             = aws_api_gateway_method.this4.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = var.arns[3]
  passthrough_behavior    = "WHEN_NO_TEMPLATES"

  request_templates = {
    "application/json" = file("${path.module}/models-in-json/delete-course-model.json")
  }

  depends_on = [
    aws_api_gateway_method.this4
  ]
}

resource "aws_api_gateway_integration_response" "this4" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this2.id
  http_method = aws_api_gateway_method.this4.http_method
  status_code = aws_api_gateway_method_response.this4.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_method_response" "this4" {
  rest_api_id     = aws_api_gateway_rest_api.this.id
  resource_id     = aws_api_gateway_resource.this2.id
  http_method     = aws_api_gateway_method.this4.http_method
  status_code     = "200"
  response_models = { "application/json" = "Empty" }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_lambda_permission" "this4" {
  statement_id  = "AllowExecutionFromAPIGatewayForDelete${title(var.names[1])}"
  action        = "lambda:InvokeFunction"
  function_name = var.function_names[3]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:eu-central-1:${data.aws_caller_identity.this.account_id}:${aws_api_gateway_rest_api.this.id}/*/${aws_api_gateway_method.this4.http_method}${aws_api_gateway_resource.this.path}/*"
}

//get-all-courses

resource "aws_api_gateway_method" "this5" {
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.this.id //resource_id - (Required) API resource ID
  rest_api_id   = aws_api_gateway_rest_api.this.id //rest_api_id - (Required) ID of the associated REST API
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "this5" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.this.id
  http_method             = aws_api_gateway_method.this5.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = var.arns[4]

  depends_on = [
    aws_api_gateway_method.this5
  ]
}

resource "aws_api_gateway_integration_response" "this5" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this5.http_method
  status_code = aws_api_gateway_method_response.this5.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_method_response" "this5" {
  rest_api_id     = aws_api_gateway_rest_api.this.id
  resource_id     = aws_api_gateway_resource.this.id
  http_method     = aws_api_gateway_method.this5.http_method
  status_code     = "200"
  response_models = { "application/json" = "Empty" }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_lambda_permission" "this5" {
  statement_id  = "AllowExecutionFromAPIGatewayForGetAll${var.names[1]}"
  action        = "lambda:InvokeFunction"
  function_name = var.function_names[4]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:eu-central-1:${data.aws_caller_identity.this.account_id}:${aws_api_gateway_rest_api.this.id}/*/${aws_api_gateway_method.this5.http_method}${aws_api_gateway_resource.this.path}"
}

//get-all-authors

resource "aws_api_gateway_resource" "this3" {
  rest_api_id = aws_api_gateway_rest_api.this.id               //rest_api_id - (Required) ID of the associated REST API and id - ID of the REST API
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id //root_resource_id - Resource ID of the REST API's root
  path_part   = var.names[2]
}

# module "api-gateway-enable-cors-3" {
#   source          = "squidfunk/api-gateway-enable-cors/aws"
#   version         = "0.3.3"
#   api_id          = aws_api_gateway_rest_api.this.id
#   api_resource_id = aws_api_gateway_resource.this3.id //api_resource_id - API resource identifier
# }

///// cors3

resource "aws_api_gateway_method" "cors3" {
  api_key_required = false
  authorization    = "NONE"
  http_method      = "OPTIONS"
  resource_id      = aws_api_gateway_resource.this3.id
  rest_api_id      = aws_api_gateway_rest_api.this.id
}

resource "aws_api_gateway_integration" "cors3" {
  http_method = "OPTIONS"
  resource_id = aws_api_gateway_resource.this3.id
  rest_api_id = aws_api_gateway_rest_api.this.id
  type        = "MOCK"
  //everything up is required
  connection_type  = "INTERNET"
  content_handling = "CONVERT_TO_TEXT"

  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
  timeout_milliseconds = 29000

  depends_on = [
    aws_api_gateway_method.cors3
  ]
}

resource "aws_api_gateway_method_response" "cors3" {
  http_method = "OPTIONS"
  resource_id = aws_api_gateway_resource.this3.id
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false
    "method.response.header.Access-Control-Allow-Methods" = false
    "method.response.header.Access-Control-Allow-Origin"  = false
    "method.response.header.Access-Control-Max-Age"       = true
  }
  rest_api_id = aws_api_gateway_rest_api.this.id
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.cors3
  ]
}

resource "aws_api_gateway_integration_response" "cors3" {
  http_method = "OPTIONS"
  resource_id = aws_api_gateway_resource.this3.id
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Authorization,Content-Type,X-Amz-Date,X-Amz-Security-Token,X-Api-Key'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,HEAD,GET,POST,PUT,PATCH,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Max-Age"       = "'7200'"
  }
  rest_api_id = aws_api_gateway_rest_api.this.id
  status_code = "200"

  depends_on = [
    aws_api_gateway_method_response.cors3
  ]
}

//

resource "aws_api_gateway_method" "this6" {
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.this3.id //resource_id - (Required) API resource ID
  rest_api_id   = aws_api_gateway_rest_api.this.id  //rest_api_id - (Required) ID of the associated REST API
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "this6" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.this3.id
  http_method             = aws_api_gateway_method.this6.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = var.arns[5]

  depends_on = [
    aws_api_gateway_method.this6
  ]
}

resource "aws_api_gateway_integration_response" "this6" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this3.id
  http_method = aws_api_gateway_method.this6.http_method
  status_code = aws_api_gateway_method_response.this6.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_method_response" "this6" {
  rest_api_id     = aws_api_gateway_rest_api.this.id
  resource_id     = aws_api_gateway_resource.this3.id
  http_method     = aws_api_gateway_method.this6.http_method
  status_code     = "200"
  response_models = { "application/json" = "Empty" }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_lambda_permission" "this6" {
  statement_id  = "AllowExecutionFromAPIGatewayForGet${var.names[2]}"
  action        = "lambda:InvokeFunction"
  function_name = var.function_names[5]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:eu-central-1:${data.aws_caller_identity.this.account_id}:${aws_api_gateway_rest_api.this.id}/*/${aws_api_gateway_method.this5.http_method}${aws_api_gateway_resource.this3.path}"
}

# //stage

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "${var.environment}-server"
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.this.body))
  }
  lifecycle {
    create_before_destroy = true
  }
}
