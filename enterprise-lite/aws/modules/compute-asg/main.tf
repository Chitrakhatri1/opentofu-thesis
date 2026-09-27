data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_security_group" "workload" {
  name_prefix = "${var.name_prefix}-workload-"
  description = "HTTP only from the enterprise-lite ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    description = "HTTPS to routed AWS services such as the S3 gateway endpoint"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-workload-sg" })
  lifecycle { create_before_destroy = true }
}

resource "aws_launch_template" "workload" {
  name_prefix   = "${var.name_prefix}-"
  image_id      = data.aws_ssm_parameter.al2023_ami.value
  instance_type = var.instance_type

  iam_instance_profile { name = var.instance_profile_name }
  vpc_security_group_ids = [aws_security_group.workload.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      encrypted             = true
      volume_size           = 8
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  user_data = base64encode(<<-EOT
    #!/bin/bash
    set -euo pipefail
    install -d -m 0755 /opt/thesis-web
    cat > /opt/thesis-web/index.html <<'HTML'
    <!doctype html><html><body><h1>OpenTofu enterprise-lite</h1><p>Private replaceable workload reached through the load balancer.</p></body></html>
    HTML
    cat > /etc/systemd/system/thesis-web.service <<'UNIT'
    [Unit]
    Description=Thesis demonstration web service
    After=network.target
    [Service]
    ExecStart=/usr/bin/python3 -m http.server 80 --directory /opt/thesis-web
    Restart=always
    [Install]
    WantedBy=multi-user.target
    UNIT
    systemctl daemon-reload
    systemctl enable --now thesis-web.service
  EOT
  )

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${var.name_prefix}-workload" })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge(var.tags, { Name = "${var.name_prefix}-workload-volume" })
  }

  tags = var.tags
}

resource "aws_autoscaling_group" "workload" {
  name                      = "${var.name_prefix}-asg"
  min_size                  = 1
  desired_capacity          = 1
  max_size                  = 1
  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = [var.target_group_arn]
  health_check_type         = "ELB"
  health_check_grace_period = 180
  force_delete              = true

  launch_template {
    id      = aws_launch_template.workload.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(var.tags, { Name = "${var.name_prefix}-workload" })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences { min_healthy_percentage = 0 }
  }
}
