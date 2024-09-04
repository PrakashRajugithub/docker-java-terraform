resource "aws_vpc" "new-vpc" {
  cidr_block           = "10.2.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name      = "new-vpc"
    Terraform = "True"
  }
}

#Public Subnets

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.new-vpc.id
  count                   = length(data.aws_availability_zones.available.names)
  cidr_block              = element(var.pub_cidr, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = "true"

  tags = {
    Name      = "Pub-subnet-${count.index + 1}"
    Terraform = "True"
  }
}


# Internet GW

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.new-vpc.id

  tags = {
    Name = "new-vpc-igw"
  }
  depends_on = [
    aws_vpc.new-vpc
  ]
}


#Route Table

resource "aws_route_table" "new_rt" {
  vpc_id = aws_vpc.new-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "new-route-table"
  }
}

# Subnet Association/Route table association
# Pub subnets association

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public[*].id)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.new_rt.id
}

resource "aws_security_group" "demo-sg" {
  name        = "allow tomcat traffic"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.new-vpc.id

#   ingress {
#     description = "ssh admin"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
#     # The above line is to get IP. "chomp" used for 'if there is any spaces in between the line it will delete the spaces'
#   }

  ingress {
    description = "ApacheTomcat"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name      = "demo-sg"
    Terraform = "True"
  }
}