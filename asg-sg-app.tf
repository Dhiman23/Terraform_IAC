resource "aws_security_group" "asg-app-sg" {
  name        = "asg-app-sg"
  description = "ASG Security Group"
  vpc_id      = aws_vpc.my-vpc.id

  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = [aws_security_group.alb-sg-app.id]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "asg-app-sg"
  }


}