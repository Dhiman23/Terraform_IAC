resource "aws_security_group" "alb-sg-web" {
  name        = "alb-sg-web"
  description = "ALB Security Group"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg-web"
  }
}