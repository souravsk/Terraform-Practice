# In Terrform it's not like the normal programming language where it will excute it line by line.
#what we do it we give a buleprint what we want and terrform do the rest of it we don't give instration to follow we just say what we want


provider "aws"{
    region = "ap-south-1"
}

# it is simple as it looks "Provider" where we provied the Provider we are using in you case it is AWS 
#region is what we like to use is used ap-south which is mumbai

# SYNTEX FOR RESOURCE
#resource "<provider>_<resource_type>" "name"{
#    config options..
#    key = "value"
#    key2 = "another value"
#}

resource "aws_instance" "my-server"{
    ami = "ami-062df10d14676e201" #this ami is what give by aws which is OS machine number
    instance_type = "t2.micro"
    tags = { #tag is used to just give the tag to that instance to so that it can be identified easly
        name = "created-by-terraform"
    }
}
 