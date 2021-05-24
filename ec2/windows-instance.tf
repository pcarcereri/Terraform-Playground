resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

resource "random_password" "winrm_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_string" "winrm_user" {
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
  user_data     = <<EOF
<powershell>
net user ${random_string.winrm_user.result} '${random_password.winrm_password.result}' /add /y
net localgroup administrators ${random_string.winrm_user.result} /add

winrm quickconfig -q
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="300"}'
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

netsh advfirewall firewall add rule name="WinRM 5985" protocol=TCP dir=in localport=5985 action=allow
netsh advfirewall firewall add rule name="WinRM 5986" protocol=TCP dir=in localport=5986 action=allow

net stop winrm
sc.exe config winrm start=auto
net start winrm
</powershell>
EOF

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
    user = random_string.winrm_user.result
    password = random_password.winrm_password.result
  }
}

output "public_dns" {
  value = ["${aws_instance.win-example.*.public_dns}"]
}

output "public_ip" {
  value = ["${aws_instance.win-example.*.public_ip}"]
}

output "winrm_user_password" {
  value = ["${random_password.winrm_password.result}"]
  sensitive = true
}

output "winrm_user_name" {
  value = ["${random_string.winrm_user.result}"]
}

