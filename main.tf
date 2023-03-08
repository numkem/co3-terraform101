terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.57.1"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

locals {
  name = "terraform101"
  server_count = {
    webserver = 3
  }
}
