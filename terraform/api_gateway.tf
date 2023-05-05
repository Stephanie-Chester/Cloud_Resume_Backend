resource "aws_api_gateway_rest_api" "visitorCounter" {
  name        = "visitorCounter"
  description = "Visitor Counter API"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
resource "aws_api_gateway_resource" "cors_resource" {
  path_part   = "IncrementVisitorCounter"
  parent_id   = aws_api_gateway_rest_api.visitorCounter.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.visitorCounter.id
}
resource "aws_api_gateway_method" "increment_visitors_method" {
  rest_api_id   = aws_api_gateway_rest_api.visitorCounter.id
  resource_id   = aws_api_gateway_resource.cors_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.visitorCounter.id
  resource_id = aws_api_gateway_resource.cors_resource.id
  http_method = aws_api_gateway_method.increment_visitors_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = [aws_api_gateway_method.increment_visitors_method]
}
resource "aws_api_gateway_integration" "lambda_visitor_integration" {
  rest_api_id             = aws_api_gateway_rest_api.visitorCounter.id
  resource_id             = aws_api_gateway_resource.cors_resource.id
  http_method             = aws_api_gateway_method.increment_visitors_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.DynamoDBVisitorFunction.invoke_arn
}

resource "aws_api_gateway_integration_response" "VisitorIntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.visitorCounter.id
  resource_id = aws_api_gateway_resource.cors_resource.id
  http_method = aws_api_gateway_method.increment_visitors_method.http_method
  status_code = aws_api_gateway_method_response.method_response_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [
    aws_api_gateway_integration.lambda_visitor_integration
  ]
}
resource "aws_lambda_permission" "apigw-visitCounter" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.DynamoDBVisitorFunction.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.visitorCounter.execution_arn}/*"
}
resource "aws_api_gateway_deployment" "visitor_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.visitorCounter.id
  triggers = {
    "redeployment" = sha1(jsonencode([
      aws_api_gateway_resource.cors_resource.id,
      aws_api_gateway_method.increment_visitors_method.http_method,
      aws_api_gateway_integration.lambda_visitor_integration.id,
      aws_api_gateway_integration_response.VisitorIntegrationResponse.id,
      aws_api_gateway_method_response.method_response_200.id
    ]))
  }
  lifecycle {
    create_before_destroy = false
  }
}
resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.visitor_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.visitorCounter.id
  stage_name    = "default"
}
resource "aws_api_gateway_usage_plan" "incrementVisitor-UsagePlan" {
  name = "visitorCount_usage_plan"
  api_stages {
    api_id = aws_api_gateway_rest_api.visitorCounter.id
    stage  = aws_api_gateway_stage.api_stage.stage_name
  }

}
resource "aws_api_gateway_api_key" "visitor_api_key" {
  name        = "incrementVisitorCount-Key"
  description = "Visitor Counter Api Key"
  enabled     = false
}
resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.visitor_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.incrementVisitor-UsagePlan.id
}


# OPTIONS HTTP method.
resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.visitorCounter.id
  resource_id   = aws_api_gateway_resource.cors_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS method response.
resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.visitorCounter.id
  resource_id = aws_api_gateway_resource.cors_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = 200
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Headers" = true
  }
  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [aws_api_gateway_method.options_method]
}

# OPTIONS integration.
resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.visitorCounter.id
  resource_id = aws_api_gateway_resource.cors_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200

        depends_on = [aws_api_gateway_method.options_method]
      }
    )
  }
}

# OPTIONS integration response.
resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.visitorCounter.id
  resource_id = aws_api_gateway_resource.cors_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.options_200]
}