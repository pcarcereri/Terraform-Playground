data "template_file" "user_data" {
  template = file("${path.module}/scripts/UserDataTemplate.tpl")
  vars = {
    Username = var.INSTANCE_USERNAME
    Password = random_string.winrm_password.result
  }
}