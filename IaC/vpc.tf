# VPC Starting Configurations 
resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr_block

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.env}-${local.eks_name}-vpc"
  }
}


# Internet-Gateway 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.env}-${local.eks_name}-igw"
  }
}


# Private-Subnets 
resource "aws_subnet" "private_zone1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = local.private_subnet_cidr_1
  availability_zone = local.zone1

  tags = {
    "Name" = "${local.env}-${local.eks_name}-private-${local.zone1}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "private_zone2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = local.private_subnet_cidr_2
  availability_zone = local.zone2

  tags = {
    "Name" = "${local.env}-${local.eks_name}-private-${local.zone2}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "private_zone3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = local.private_subnet_cidr_3
  availability_zone = local.zone3

  tags = {
    "Name" = "${local.env}-${local.eks_name}-private-${local.zone3}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
  }
}


# Public-Subnets 
resource "aws_subnet" "public_zone1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = local.public_subnet_cidr_1
  availability_zone = local.zone1
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${local.env}-${local.eks_name}-public-${local.zone1}"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "public_zone2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = local.public_subnet_cidr_2
  availability_zone = local.zone2
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${local.env}-${local.eks_name}-public-${local.zone2}"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "public_zone3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = local.public_subnet_cidr_3
  availability_zone = local.zone3
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${local.env}-${local.eks_name}-public-${local.zone3}"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
  }
}

# Elastic IPs for NAT
resource "aws_eip" "nat_1" {
  domain = "vpc"
  tags = { Name = "${local.env}-${local.eks_name}-nat1" }
}

resource "aws_eip" "nat_2" {
  domain = "vpc"
  tags = { Name = "${local.env}-${local.eks_name}-nat2" }
}

resource "aws_eip" "nat_3" {
  domain = "vpc"
  tags = { Name = "${local.env}-${local.eks_name}-nat3" }
}


# NAT 
resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id     = aws_subnet.public_zone1.id
  tags = {
    Name = "${local.env}-${local.eks_name}-nat1"
  }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id     = aws_subnet.public_zone2.id
  tags = {
    Name = "${local.env}-${local.eks_name}-nat2"
  }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_3" {
  allocation_id = aws_eip.nat_3.id
  subnet_id     = aws_subnet.public_zone3.id
  tags = {
    Name = "${local.env}-${local.eks_name}-nat3"
  }
  depends_on = [aws_internet_gateway.igw]
}

# Route Tables
resource "aws_route_table" "private_zone1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1.id
  }

  tags = {
    Name = "${local.env}-${local.eks_name}-private-rt-${local.zone1}"
  }
}

resource "aws_route_table" "private_zone2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_2.id
  }

  tags = {
    Name = "${local.env}-${local.eks_name}-private-rt-${local.zone2}"
  }
}

resource "aws_route_table" "private_zone3" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_3.id
  }

  tags = {
    Name = "${local.env}-${local.eks_name}-private-rt-${local.zone3}"
  }
}


resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
      Name = "${local.env}-${local.eks_name}-publicrt"
    }
}

# Route Tables Association
resource "aws_route_table_association" "private_zone1" {
    subnet_id      = aws_subnet.private_zone1.id
    route_table_id = aws_route_table.private_zone1.id
}

resource "aws_route_table_association" "private_zone2" {
    subnet_id      = aws_subnet.private_zone2.id
    route_table_id = aws_route_table.private_zone2.id
}

resource "aws_route_table_association" "private_zone3" {
  subnet_id      = aws_subnet.private_zone3.id
  route_table_id = aws_route_table.private_zone3.id
}

resource "aws_route_table_association" "public_zone1" {
    subnet_id = aws_subnet.public_zone1.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_zone2" {
    subnet_id = aws_subnet.public_zone2.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_zone3" {
  subnet_id      = aws_subnet.public_zone3.id
  route_table_id = aws_route_table.public.id
}
