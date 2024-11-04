# store the terraform state file in s3 and lock with dynamodb
terraform {
  backend "s3" {
    bucket         = "alex77063-terraform-remote-state"
    key            = "terraform-module/rentzone/terraform.tfstate"
    region         = "us-east-1"
    profile        = "terraform-user"
    dynamodb_table = "terraform-state-lock"
  }
}