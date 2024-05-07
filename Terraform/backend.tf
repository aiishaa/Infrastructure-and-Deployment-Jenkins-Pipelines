terraform {
  backend "s3" {
    bucket         = "s3-terraform-backend-bucket-1234"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dynamo-state-lock-table"
  }
}