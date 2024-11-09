resource "aws_security_group" "db-sg" {
  name        = "DB-sg"
  description = "ALB Security Group"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {

    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg-app.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}