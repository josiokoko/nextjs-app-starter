# terraform {
#   required_version = ">= 1.0.11"

#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = ">= 3.68.0"
#     }
#     random = {
#       source  = "hashicorp/random"
#       version = ">= 3.1.0"
#     }
#   }
# }


provider "aws" {
  region = var.region
}


terraform {
  backend "s3" {
    bucket = "joe-terraform-2023-05-05"
    key    = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "onyxquity-fargate-terraform-lock"
  }
}