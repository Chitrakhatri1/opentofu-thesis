output "instance_id" {
  description = "ID of the demonstration EC2 instance."
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IPv4 address of the demonstration instance."
  value       = aws_instance.this.public_ip
}

output "public_dns" {
  description = "Public DNS name of the demonstration instance."
  value       = aws_instance.this.public_dns
}

output "security_group_id" {
  description = "ID of the instance security group."
  value       = aws_security_group.this.id
}

output "ami_id" {
  description = "Amazon Linux 2023 AMI selected through SSM."
  value       = data.aws_ssm_parameter.al2023_ami.value
}
