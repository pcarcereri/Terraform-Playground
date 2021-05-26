data "template_cloudinit_config" "cloudinit-example" {
  gzip          = false
  base64_encode = false

  part {
    filename = "UserDataTemplate"
    # content_type = "text/cloud-config"
    #content_type = "text/x-shellscript"
    content = data.template_file.user_data.rendered
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/scripts/UserDataTemplate.tpl")
  vars = {
    Username = var.INSTANCE_USERNAME
    Password = random_string.winrm_password.result
  }
}