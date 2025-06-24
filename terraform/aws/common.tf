# Configure the AWS provider

# Create a resource group
#resource "aws_resourcegroups_group" "rg" {
#  name     = var.resource_group_name
#  resource_query {
#    query = <<JSON
#{
#  "ResourceTypeFilters": [
#    "AWS::AllSupported"
#  ],
#  "TagFilters": [
#    {
#      "Key": "ResourceGroup",
#      "Values": [var.resource_group_name]
#    }
#  ]
#}
#JSON
#  }
#}

data "aws_availability_zones" "available" {
  state = "available"
}

# Create network interfaces for virtual machines
#For VM1
resource "aws_network_interface" "vm_nic_1" {
  subnet_id       = aws_subnet.nat_gateway.id
  private_ips     = ["10.0.1.4"]
  security_groups = [aws_security_group.bot_sg.id]
  tags = {
    Name          = join("-", [var.resource_group_name, "vm_nic1"])
    ResourceGroup = var.resource_group_name
  }
}

#For VM2,3...
resource "aws_network_interface" "vm_nic" {
  count           = var.vm_count - 1
  subnet_id       = aws_subnet.subnet[0].id
  private_ips     = ["10.0.2.${count.index + 5}"]
  security_groups = [aws_security_group.bot_sg.id]
  tags = {
    Name          = join("-", [var.resource_group_name, "vm_nic${count.index + 2}"])
    ResourceGroup = var.resource_group_name
  }
}


# Create a subnet for virtual machines
resource "aws_subnet" "subnet" {
  count             = 2
  vpc_id            = aws_vpc.vnet.id
  cidr_block        = "10.0.${count.index + 2}.0/24"
  availability_zone = data.aws_availability_zones.available.names["${count.index}"]
  tags = {
    Name                              = join("-", [var.resource_group_name, "vm-subnet${count.index + 1}"])
    ResourceGroup                     = var.resource_group_name
    "kubernetes.io/role/internal-elb" = 1
  }
  depends_on = [aws_nat_gateway.nat_gateway]
}

# Create a virtual network for virtual machines
resource "aws_vpc" "vnet" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name          = join("-", [var.resource_group_name, "vmvnet"])
    ResourceGroup = var.resource_group_name
  }
  enable_dns_hostnames = true
  enable_dns_support   = true
}

####  Public subnet is reqired for NAT Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vnet.id
  tags = {
    Name          = join("-", [var.resource_group_name, "igw"])
    ResourceGroup = var.resource_group_name
  }
}

resource "aws_subnet" "nat_gateway" {
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.vnet.id
  tags = {
    Name                     = join("-", [var.resource_group_name, "public-subnet"])
    ResourceGroup            = var.resource_group_name
    "kubernetes.io/role/elb" = 1
  }
  map_public_ip_on_launch = true
  depends_on              = [aws_internet_gateway.igw]
}

resource "aws_route_table" "igw_gateway" {
  vpc_id = aws_vpc.vnet.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "igw_gateway" {
  subnet_id      = aws_subnet.nat_gateway.id
  route_table_id = aws_route_table.igw_gateway.id
}

####  NAT Gateway setup

resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.nat_gateway.id
  tags = {
    Name          = join("-", [var.resource_group_name, "nat-gw"])
    ResourceGroup = var.resource_group_name
  }
}

resource "aws_route_table" "nat_gateway" {
  vpc_id = aws_vpc.vnet.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "nat_gateway" {
  count          = 2
  subnet_id      = aws_subnet.subnet["${count.index}"].id
  route_table_id = aws_route_table.nat_gateway.id
}

#### 

# Create a public IP for the first VM
resource "aws_eip" "public_ip" {
  vpc                       = true
  network_interface         = aws_network_interface.vm_nic_1.id
  associate_with_private_ip = "10.0.1.4"
  tags = {
    Name          = join("-", [var.resource_group_name, "vm1-pip"])
    ResourceGroup = var.resource_group_name
  }
  depends_on = [aws_internet_gateway.igw]
}

# Security Group
resource "aws_security_group" "bot_sg" {
  name   = join("-", [var.resource_group_name, "bot-sg"])
  vpc_id = aws_vpc.vnet.id

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Nginx Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Nginx Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Internal Access"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vnet.cidr_block]
  }

  ingress {
    description = "Internal Access"
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = [aws_vpc.vnet.cidr_block]
  }

  ingress {
    description = "ICMP Access (Ping) - Internal IPs"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.vnet.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name          = join("-", [var.resource_group_name, "bot-sg"])
    ResourceGroup = var.resource_group_name
  }
}
