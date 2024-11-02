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
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id
}

resource "aws_eip" "eip" {
  domain = vpc

}

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
