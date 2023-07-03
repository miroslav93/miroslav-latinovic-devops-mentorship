provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "task-12-webserver-tf" {
  ami           = "ami-07c6322fcdbe32922" 
  instance_type = "t2.micro" 
  key_name      = "miroslav-latinovic-web-server-key"
  subnet_id     = "subnet-0598fd94364953bdf"
  security_groups = ["sg-080e0a51e5dfa3657"]
  tags = {
    Name = "task-12-webserver-tf-1"
  }
}

resource "aws_instance" "task-12-webserver-tf-2" {
  ami           = "ami-07c6322fcdbe32922" 
  instance_type = "t2.micro" 
  key_name      = "miroslav-latinovic-web-server-key"
  subnet_id     = "subnet-0598fd94364953bdf"
  security_groups = ["sg-080e0a51e5dfa3657"]
  tags = {
    Name = "task-12-webserver-tf-2"
  }
}