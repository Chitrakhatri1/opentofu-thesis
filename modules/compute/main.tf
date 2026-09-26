data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_security_group" "this" {
  name_prefix = "${var.name_prefix}-web-"
  description = "HTTP access for the thesis demonstration workload"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.allowed_http_security_group_ids) == 0 ? [] : [1]

    content {
      description     = "HTTP from the Application Load Balancer"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = var.allowed_http_security_group_ids
    }
  }

  egress {
    description = "Allow outbound traffic for package installation and AWS APIs"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-web-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "this" {
  ami                         = data.aws_ssm_parameter.al2023_ami.value
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = true

  user_data = <<-EOT
    #!/bin/bash
    set -euo pipefail
    dnf install -y httpd
    printf '%s\n' '<!doctype html><html><body><h1>OpenTofu thesis baseline</h1><p>Provisioned successfully.</p></body></html>' > /var/www/html/index.html
    systemctl enable --now httpd
  EOT

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-web"
  })
}
