terraform {
  backend "s3" {
    bucket = "production-openedx-terraform-statefile"
    key    = "eks-terraform/terraform.tfstate"
    region = "us-east-2"
  }
}
