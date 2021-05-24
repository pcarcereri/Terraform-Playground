resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

resource "random_password" "winrm_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

data "template_file" "user_data" {
  template = file("scripts/user_data.tpl")
  vars = {
    Username = var.INSTANCE_USERNAME
    Password = var.INSTANCE_PASSWORD
    Group    = "administrators"
  }
}

# https://github.com/dstamen/Terraform/blob/master/deploy-aws-ec2/main.tf
resource "aws_instance" "win-example" {
  depends_on        = [random_password.winrm_password]
  ami               = data.aws_ami.windows-ami.image_id
  get_password_data = true
  instance_type     = "t2.micro"
  key_name          = aws_key_pair.mykey.key_name
  # https://gist.github.com/RulerOf/10af91c7fa9e5a951467b94f712d8d9f
  user_data = data.template_file.user_data.rendered

  provisioner "file" {
    source      = "scripts/SetupSqlServer.ps1"
    destination = "C:/SetupSqlServer.ps1"
  }

  provisioner "remote-exec" {
    inline = [
      "powershell -File C:/SetupSqlServer.ps1"
    ]
  }

  tags = {
    CreateDate = timestamp()
    UserARN    = data.aws_caller_identity.current.arn
    AccountID  = data.aws_caller_identity.current.account_id
  }

  connection {
    host     = coalesce(self.public_ip, self.private_ip)
    type     = "winrm"
    timeout  = "3m"
    user     = var.INSTANCE_USERNAME
    password = var.INSTANCE_PASSWORD
  }
}

output "public_dns" {
  value = ["${aws_instance.win-example.*.public_dns}"]
}

output "public_ip" {
  value = ["${aws_instance.win-example.*.public_ip}"]
}

output "winrm_user_password" {
  value     = ["${var.INSTANCE_PASSWORD}"]
  sensitive = true
}

output "winrm_user_name" {
  value = ["${var.INSTANCE_USERNAME}"]
}

