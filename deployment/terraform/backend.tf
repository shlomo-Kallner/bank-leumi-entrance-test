terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "bank-leumi-entrance-exam"
    key    = "test-spoke/env"
    region = "us-east-1"
    dynamodb_table = "bank-leumi-entrance-exam-lock-test-spoke"
  }
}

data "aws_caller_identity" "current" {}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags {
        namespace = "bank-leumi-entrance-exam"
        application = "simple-expression-calc-app"
        author = "Shlomo Kallner"
        author_email = "shlomo.kallner@gmail.com"
    }
  }
}
