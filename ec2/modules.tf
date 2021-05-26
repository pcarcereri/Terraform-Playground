module "standardEC2" {
  source             = "./modules/ec2"
  PATH_TO_PUBLIC_KEY = "./keys/mykey.pub"
  INSTANCE_USERNAME  = "Terraform"
}
