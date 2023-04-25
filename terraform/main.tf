terraform {
  cloud {
    organization = "AWS_CloudResume"
    workspaces {
      name = "AWS_CloudResume_backend"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "DynamoDBLambdaRole" {
  name               = "DynamoDBLambdaRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    } 
  ]
}
EOF
}
data "template_file" "dynamoDBlambdapolicy" {
  template = file("${path.module}/policy.json")
}
resource "aws_iam_policy" "DynamoDBLambdaPolicy" {
  name        = "DynamoDBLambdaPolicy"
  path        = "/"
  description = "IAM policy for DynamoDB lambda functions"
  policy      = data.template_file.dynamoDBlambdapolicy.rendered
}
resource "aws_iam_role_policy_attachment" "DynamoDBLambdaRolePolicy" {
  role       = aws_iam_role.DynamoDBLambdaRole.name
  policy_arn = aws_iam_policy.DynamoDBLambdaPolicy.arn
}