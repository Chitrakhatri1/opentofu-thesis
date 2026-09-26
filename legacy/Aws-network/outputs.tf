output "ami_id_used" {
  value     = data.aws_ssm_parameter.al2023_ami.value
  sensitive = true
}