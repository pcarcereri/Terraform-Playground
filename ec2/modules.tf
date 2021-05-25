module "standardEC2" {
    source = "./modules/ec2"
    PATH_TO_PUBLIC_KEY = "./modules/ec2/keys/mykey.pub"
    INSTANCE_USERNAME = "Terraform"
}
