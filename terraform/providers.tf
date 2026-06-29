# ═══════════════════════════════════════════════════════════════
# providers.tf — AWS connection settings
#
# WHAT THIS FILE DOES:
#   Tells Terraform you want to use AWS as your cloud provider.
#   Sets your region (Ireland = eu-west-1) and applies default
#   tags to every resource it creates.
#
# HOW TERRAFORM LOGS INTO AWS (pick ONE way):
#   1. Environment variables (what GitHub Actions uses):
#        export AWS_ACCESS_KEY_ID=AKIA...
#        export AWS_SECRET_ACCESS_KEY=...
#
#   2. AWS CLI profile (what you use on your own machine):
#        export AWS_PROFILE=terraform-access
#
#   3. Leave both blank → Terraform uses your default profile
#      from ~/.aws/credentials
# ═══════════════════════════════════════════════════════════════

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

#=============================
# Terraform to AWS connection
#=============================
provider "aws" {
  region = var.aws_region

  profile = var.aws_profile != "" ? var.aws_profile : null

  # default tags for aws resources
  default_tags {
    tags = {
      Project   = "ci-cd-project"
      ManagedBy = "Terraform"
    }
  }
}