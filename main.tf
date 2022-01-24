terraform {
  backend "s3" {
    bucket = "cyj-state-bucket"
    region         = "ap-northeast-2"
    dynamodb_table = "state-locking-test"
    encrypt        = true
  }
}

# terraform {
#   required_providers {
#     aws = {
#       source = "hashicorp/aws"
#       version = "~> 3.27"
#     }
#   }
#   required_version = ">= 0.14.9"
# }

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = "private"
  cors_rule {
    allowed_headers = [
      "*",
    ]
    allowed_methods = [
      "GET",
      "POST",
      "PUT",
    ]
    allowed_origins = [
      "*",
    ]
    expose_headers  = []
    max_age_seconds = 60000
  }
}

resource "aws_ecr_repository" "test" {
  count = var.env == "test" ? 1 : 0
  name                 = "test"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "aws_dynamodb_table" "state-locking" {
  name = "state-locking-test"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
}
