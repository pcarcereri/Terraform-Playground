terraform {
  backend "s3" {
    bucket = "terraform-tfstate-carcereri"
    key    = "terraform/ec2demo"
    region = "eu-central-1"
  }
}
