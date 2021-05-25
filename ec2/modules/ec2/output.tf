output "public_dns" {
  value = ["${aws_instance.win-example.*.public_dns}"]
}

output "public_ip" {
  value = ["${aws_instance.win-example.*.public_ip}"]
}

output "winrm_user_password" {
  value     = ["${random_string.winrm_password.result}"]
  sensitive = true
}

output "winrm_user_name" {
  value = ["${var.INSTANCE_USERNAME}"]
}