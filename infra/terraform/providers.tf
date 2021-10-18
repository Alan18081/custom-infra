terraform {
  backend "s3" {
    bucket = "tf-balder-state"
    key = "tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  region = "us-east-2"
}