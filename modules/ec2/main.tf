terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.9.0"
    }
  }
  cloud {
    organization = "ChainSafe"
    workspaces {
      name = " " // set the workspace
    }
  }
}

// Configure the AWS Provider
provider "aws" {
  region  = var.region
  profile = "default"
}