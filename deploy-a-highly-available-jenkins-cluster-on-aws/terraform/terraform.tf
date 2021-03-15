terraform {
  backend "s3" {
    encrypt = "true"
    bucket  = "bwr-terraform-state-aws-pipeline"
    region  = "us-east-1"
    key     = "jenkins/terraform.tfstate"
  }
}

provider "aws" {
  region                  = var.region
  shared_credentials_file = var.shared_credentials_file
  profile                 = var.aws_profile
}
