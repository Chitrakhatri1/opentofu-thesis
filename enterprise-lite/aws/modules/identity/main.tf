resource "aws_iam_role" "workload" {
  name = "${var.name_prefix}-workload-role"
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "storage" {
  name = "${var.name_prefix}-storage-access"
  role = aws_iam_role.workload.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = var.bucket_arn
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = "${var.bucket_arn}/application/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "workload" {
  name = "${var.name_prefix}-workload-profile"
  role = aws_iam_role.workload.name
  tags = var.tags
}
