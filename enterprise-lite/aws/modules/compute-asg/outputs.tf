output "autoscaling_group_name" { value = aws_autoscaling_group.workload.name }
output "launch_template_id" { value = aws_launch_template.workload.id }
output "security_group_id" { value = aws_security_group.workload.id }
