terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.33.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.2.0"
    }
  }

  cloud {
    organization = "cloudproalex"

    workspaces {
      name = "CloudResumeChallenge"
    }
  }

}

provider "aws" {
  region = var.region
}

