output "vpc_id" { value = aws_vpc.this.id }
output "public_subnet_ids" { value = { for key, subnet in aws_subnet.public : key => subnet.id } }
output "private_subnet_ids" { value = { for key, subnet in aws_subnet.private : key => subnet.id } }
output "s3_endpoint_id" { value = aws_vpc_endpoint.s3.id }
