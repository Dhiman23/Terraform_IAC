terraform {
  backend "s3" {
    bucket = "terra-bucket-12"
    key    = "3tier/terraform.tfstate"
    region = "us-east-1"
  }
}