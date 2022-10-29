provider "aws"{
    region = "ap-south-1"
}

#create a veriable 
# variable "subnet_prefix"{
#   description = "cider block for subnet"
#   #default
#   #type = string 
# }

#Create VPC
resource "aws_vpc" "pro-vpc"{
    cidr_block = "10.0.0.0/16"
    tags = {
      "Name" = "Production"
    }
}

#Create the internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.pro-vpc.id

  tags = {
    "Name" = "Production-gw"
  }
}

#create custom route table

resource "aws_route_table" "pro-route-table" {
  vpc_id = aws_vpc.pro-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    "Name" = "Production-route"
  }
}

#create a subnet

resource "aws_subnet" "subnet-1" {
  vpc_id = aws_vpc.pro-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    "Name" = "Production-subnet"
  }
}

# Associate subnet with Route Tabel

resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.pro-route-table.id
}

#Create security group

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.pro-vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

    ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

    ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

#Create a network interface with an ip in the subnet    

resource "aws_network_interface" "web-server" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}

#create ip network to assign for everyone

resource "aws_eip" "one" {
  vpc = true
  network_interface = aws_network_interface.web-server.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw]
}

# create ubuntu server and install/enable apache2

resource "aws_instance" "web-server-instance" {
  ami = "ami-062df10d14676e201"
  instance_type = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name = "AWS_key"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web-server.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo Hey these is Sourav from the terraform Editer. > /var/www/html/index.html'
              EOF
  
  tags = {
    "Name" = "web server"
  }
}

output "web_server_ip" {

  value = aws_eip.one.public_ip

}