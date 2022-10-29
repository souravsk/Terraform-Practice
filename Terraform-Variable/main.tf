provider "aws" {
    region = "ap-south-1"
}

resource "aws_instance" "test_server" {
  ami = "ami-062df10d14676e201"
  instance_type = "t2.micro"
  availability_zone = var.availab_Zone
  key_name = "AWS_key"
}

variable "availab_Zone" {
  description = "strongig the availavb zone"
}