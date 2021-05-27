data "template_cloudinit_config" "cloudinit-example" {
  gzip          = false
  base64_encode = false

  part {
    filename = "UserDataTemplate"
    # content_type = "text/cloud-config"
    #content_type = "text/x-shellscript"
    content = data.template_file.create_winrm_user.rendered
  }

  part {
    filename = "SetupSqlServer"
    # content_type = "text/cloud-config"
    #content_type = "text/x-shellscript"
    content = data.template_file.setup_sql_server.rendered
  }

  part {
    filename = "RemoveWinRMUser"
    # content_type = "text/cloud-config"
    #content_type = "text/x-shellscript"
    content = data.template_file.remove_winrm_user.rendered
  }
}

data "template_file" "create_winrm_user" {
  template = file("${path.module}/scripts/UserDataTemplate.tpl")
  vars = {
    Username = var.INSTANCE_USERNAME
    Password = random_string.winrm_password.result
  }
}

data "template_file" "setup_sql_server" {
  template = file("${path.module}/scripts/SetupSqlServer.tpl")
}

data "template_file" "remove_winrm_user" {
  template = file("${path.module}/scripts/RemoveWinRMUser.tpl")
  vars = {
    Username = var.INSTANCE_USERNAME
    Password = random_string.winrm_password.result
  }
}