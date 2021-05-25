data "template_file" "user_data" {
  template = file("./modules/ec2/scripts/UserDataTemplate.tpl")
  vars = {
    Username = var.INSTANCE_USERNAME
    Password = random_string.winrm_password.result
  }
}