terraform {
  backend "s3" {
    key     = "terraform-me.tfstate"
    bucket  = "kis9a-terraform-states"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.63.0"
    }
  }
}
