resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_string" "random" {
  length           = 16
  special          = true
  override_special = "/@£$"
}

# https://github.com/dstamen/Terraform/blob/master/deploy-aws-ec2/main.tf
resource "aws_instance" "win-example" {
  ami               = data.aws_ami.windows-ami.image_id
  get_password_data = true
  instance_type     = "t2.micro"
  key_name      = aws_key_pair.mykey.key_name
  user_data = file("scripts/SetupWinRM.ps1")

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
    timeout  = "10m"
    user = var.INSTANCE_USERNAME
    password = random_password.password.result
  }
}

output "public_dns" {
  value = ["${aws_instance.win-example.*.public_dns}"]
}

output "public_ip" {
  value = ["${aws_instance.win-example.*.public_ip}"]
}

output "winrm_user_password" {
  value = ["${random_password.password.result}"]
  sensitive = true
}

output "winrm_user_name" {
  value = ["${var.INSTANCE_USERNAME}"]
}

