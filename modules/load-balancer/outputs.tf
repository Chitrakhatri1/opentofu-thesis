output "arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.this.arn
}

output "dns_name" {
  description = "Public DNS name of the Application Load Balancer."
  value       = aws_lb.this.dns_name
}

output "security_group_id" {
  description = "Security group attached to the Application Load Balancer."
  value       = aws_security_group.this.id
}

output "target_group_arn" {
  description = "ARN of the web target group."
  value       = aws_lb_target_group.this.arn
}
