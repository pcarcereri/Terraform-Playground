resource "aws_ebs_volume" "ebs-volume" {
  availability_zone = "eu-central-1a"
  size              = 20
  type              = "gp2"
  tags = {
    CreateDate = timestamp()
    UserARN    = data.aws_caller_identity.current.arn
    AccountID  = data.aws_caller_identity.current.account_id
  }
}

resource "aws_volume_attachment" "ebs-volume-attachment" {
  device_name = var.INSTANCE_DEVICE_NAME
  volume_id   = aws_ebs_volume.ebs-volume.id
  instance_id = aws_instance.win-example.id
  #skip_destroy = true                           
}