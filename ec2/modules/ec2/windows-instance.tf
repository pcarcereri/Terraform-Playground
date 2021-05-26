# https://github.com/dstamen/Terraform/blob/master/deploy-aws-ec2/main.tf
# https://gist.github.com/RulerOf/10af91c7fa9e5a951467b94f712d8d9f
resource "aws_instance" "win-example" {
  depends_on        = [random_string.winrm_password]
  ami               = data.aws_ami.windows-ami.image_id
  get_password_data = true
  instance_type     = "t2.micro"
  availability_zone = "eu-central-1a"
  key_name          = aws_key_pair.mykey.key_name
  user_data         = data.template_cloudinit_config.cloudinit-example.rendered

  tags = {
    CreateDate = timestamp()
    UserARN    = data.aws_caller_identity.current.arn
    AccountID  = data.aws_caller_identity.current.account_id
  }

  #provisioner "file" {
  #  source      = "${path.module}/scripts/SetupSqlServer.ps1"
  #  destination = "C:/SetupSqlServer.ps1"
  #}

  #provisioner "remote-exec" {
  #  inline = [
  #    "powershell -File C:/SetupSqlServer.ps1"
  #  ]
  #}

  #connection {
  #  host     = coalesce(self.public_ip, self.private_ip)
  #  type     = "winrm"
  #  timeout  = "3m"
  #  user     = var.INSTANCE_USERNAME
  #  password = random_string.winrm_password.result
  #}
}

