provider "aws" {
  alias  = "eu"
  region = "eu-central-1"
}

provider "aws" {
  alias  = "us"
  region = "us-east-1"
}

terraform {
  backend "s3" {}
}