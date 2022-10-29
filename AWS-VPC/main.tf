#Virtual Private Cloud (VPC) is a logically isolated network from another virtual network in the AWS cloud where you can launch the AWS resources
provider "aws"{
    region = "ap-south-1"
}

resource "aws_subnet" "name" {
    vpc_id = aws_vpc.first-vpc.id #so to get the vpc id we have to first run the vpc but we can't do that because we started yet so Terrform use the resource name so that when it is creatd it will get thet id what the subnet need
    cidr_block = "10.0.1.0/24"
    tags = {
      "Name" = "prod-subnet"
    }
}


resource "aws_vpc" "first-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      "Name" = "production"
    }
}


# Just to test or show that terraform doesn't work like normal programming language where it excute first function then seconad so what i did it i put the subnet method above the vpc. to show that it is a like blueprint to tell to terraform how to you want you server to like and it like make sure it will happen the way you wanted. 