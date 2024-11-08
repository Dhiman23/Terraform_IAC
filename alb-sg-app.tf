resource "aws_security_group" "alb-sg-app" {
  name        = "alb-sg-app"
  description = "ALB Security Group"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.asg-web-sg.id ]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg-app"
  }
}