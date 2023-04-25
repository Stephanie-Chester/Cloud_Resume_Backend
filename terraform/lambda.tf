data "archive_file" "zip_the_python_code" {

  type = "zip"

  source_dir = "${path.module}/python/"

  output_path = "${path.module}/python/lambda-function.zip"

}

resource "aws_lambda_function" "DynamoDBVisitorFunction" {
  filename      = "${path.module}/python/lambda-function.zip"
  function_name = "Visitor_Counter_Lambda_Function"
  role          = aws_iam_role.DynamoDBLambdaRole.arn
  handler       = "LambdaFunction.lambda_handler"
  runtime       = "python3.9"
}