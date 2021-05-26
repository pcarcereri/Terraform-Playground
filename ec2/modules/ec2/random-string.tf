
resource "random_string" "winrm_password" {
  length  = 16
  special = false
}