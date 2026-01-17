output "app-tier-with-dependencies_ami_id" {
  value = aws_ami_from_instance.app-tier-with-dependencies_ami.id
}

output "web-tier-with-dependencies_ami_id" {
  value = aws_ami_from_instance.web-tier-with-dependencies_ami.id
}