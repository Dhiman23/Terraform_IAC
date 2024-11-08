resource "aws_vpc" "my-vpc" {
  cidr_block = var.cidr
}
# -----------------------------------------------------------------------------------
# Tire 1
resource "aws_subnet" "web-sub1" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags={
    Name = "web-sub-1"
  }
}

resource "aws_subnet" "web-sub2" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

   tags={
    Name = "web-sub-2"
  }
}
# --------------------------------------------------------------------------------------
# Tire 2
resource "aws_subnet" "app-sub1" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false
  tags={
    Name = "app-sub-1"
  }
}

resource "aws_subnet" "app-sub2" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = false

   tags={
    Name = "app-sub-2"
  }
}

# --------------------------------------------------------------------------------------
# Tire 3
resource "aws_subnet" "db-sub1" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false
  tags={
    Name = "db-sub-1"
  }
}

resource "aws_subnet" "db-sub2" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = false

   tags={
    Name = "db-sub-2"
  }
}

# -------------------------------------------------------------------------->
# InternetGateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id
}
# -------------------------------------------------------------------------->
# EIP
resource "aws_eip" "eip" {
  domain = vpc

}

# ------------------------------------------------------------------------->
# NAT Gateway

resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.web-sub1.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

#---------------------------------------------------------------------------->
# Public routetable

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-rt"
  }
}
resource "aws_route_table_association" "rt-web-sub-1" {
  subnet_id      = aws_subnet.web-sub1
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "rt-web-sub-2" {
  subnet_id      = aws_subnet.web-sub2
  route_table_id = aws_route_table.public-rt.id
}
# --------------------------------------------------------------------------->
# Private Route table

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "rt-app-sub-1" {
  subnet_id      = aws_subnet.app-sub1
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "rt-app-sub-2" {
  subnet_id      = aws_subnet.app-sub2
  route_table_id = aws_route_table.private-rt.id
}

# ------------------------------------------------------------------------------>
# launch template for web tier
resource "aws_launch_template" "web" {
  name = "web1"
  image_id = "ami-0866a3c8686eaeeba"
  instance_type = "t2.micro"
  network_interfaces {
    device_index = 0
    security_groups = [aws_security_group.asg-web-sg.id]
  }

tag_specifications {
  resource_type = "instance"
  tags = {
    Name = "web"
  }  
}
}

# ----------------------------------------------------------------------->
# ABL web
resource "aws_alb" "web-alb" {
   name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg-web]
  subnets            = [aws_subnet.web-sub1.id,aws_subnet.web-sub2.id]

  tags = {
    Name = "web-alb"
  }
}
# ----------------------------------------------------------------------->
# Traget group web

resource "aws_lb_target_group" "web-tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my-vpc.id

   health_check {
    path    = "/"
    matcher = 200

  }
}

resource "aws_lb_listener" "web-listener" {
  load_balancer_arn = aws_alb.web-alb.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tg.arn
  }
}

# ----------------------------------------------------------------------->
# AutoScaling Group

resource "aws_autoscaling_group" "web-sg" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
  target_group_arns = [aws_lb_target_group.web-tg.arn]
  health_check_type = "EC2"
  vpc_zone_identifier = [aws_subnet.web-sub1.id,aws_subnet.web-sub2.id]
  launch_template {
    id      = aws_launch_template.web.id
    version = aws_launch_template.web.latest_version
  }
}

# ------------------------------------------------------------------------------->