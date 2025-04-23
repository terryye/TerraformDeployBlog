resource "aws_vpc" "webapp_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "webapp-vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.webapp_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.webapp_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "public-subnet-2"
  }
}
/*
resource "aws_subnet" "public_subnet_3" {
  vpc_id            = aws_vpc.webapp_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "public-subnet-3"
  }
}
*/
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.webapp_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.webapp_vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-subnet-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.webapp_vpc.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.webapp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_1_route_table_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_route_table_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}
/*
resource "aws_route_table_association" "public_subnet_3_route_table_assoc" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.public_route_table.id
}
*/
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.webapp_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id # Route internet traffic to the NAT Gateway
  }
  tags = {
    Name = "private-route-table"
  }
}

resource "aws_eip" "nat_gw_eip" {
  domain = "vpc"
  tags = {
    Name = "nat-gateway-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id # Place the NAT Gateway in a public subnet
  tags = {
    Name = "nat-gateway"
  }

  # Ensure the NAT Gateway waits for the IGW to be available
  depends_on = [aws_internet_gateway.igw]
}


resource "aws_route_table_association" "private_subnet_1_route_table_assoc" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_route_table_assoc" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

output "vpc_id" {
  value = aws_vpc.webapp_vpc.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id,
//    aws_subnet.public_subnet_3.id,
  ]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id,
  ]
}