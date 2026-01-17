# Create a new key pair for SSH access
resource "aws_key_pair" "ec2_instance_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}