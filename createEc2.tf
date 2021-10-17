provider "aws" {
 
  region   = "eu-west-1"
  profile  = "log-prd-backup"
 
}
 
resource "aws_instance" "qha-test" {
 
  ami         = "ami-0f396f98a2cc57548"
  instance_type = "t3.micro"
  subnet_id = "${aws_subnet.qha_public.id}"
  associate_public_ip_address = "true"

  key_name= "qha-keypair-test"
  vpc_security_group_ids = [aws_security_group.qha-test-sg.id]

    user_data = <<EOF
#!/bin/bash
echo "Here Starts my Server Code !!"
echo "Updating Machine..."

sudo apt-get update

echo "Installing nginx..."

sudo apt-get install -y nginx

echo "Making new page..."

echo "hello world of Logistics" > /tmp/index.nginx-debian.html
sudo mv /tmp/index.nginx-debian.html /var/www/html/index.nginx-debian.html
sudo chmod 655 /var/www/html/index.nginx-debian.html

echo "Here my Script is Finished !!"
EOF
 
  tags = {
    Name = "QHA-TEST"
  } 
}

resource "aws_security_group" "qha-test-sg" {
  description = "QHA Test security groupg"
  vpc_id      = aws_vpc.qha_vpc.id

  egress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
 ingress                = [
   {
     cidr_blocks      = [ "3.120.72.24/32", ]
     description      = "ssh from vpn"
     from_port        = 22
     ipv6_cidr_blocks = []
     prefix_list_ids  = []
     protocol         = "tcp"
     security_groups  = []
     self             = false
     to_port          = 22
  },
   {
     cidr_blocks      = [ "3.120.72.24/32", ]
     description      = "nginx from vpn"
     from_port        = 80
     ipv6_cidr_blocks = []
     prefix_list_ids  = []
     protocol         = "tcp"
     security_groups  = []
     self             = false
     to_port          = 80
  },
  ]
}

output "ec2_server_ip" {
  value = "${aws_instance.qha-test.public_ip}"
  description = "PublicIP address details"
}

resource "aws_key_pair" "qha-keypair-test" {
  key_name   = "qha-keypair-test"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCtByjOVWLZMp/rcFxFCttce5HiWVgOHleDboql6kvW4BG+jclvgTH54HORtSYhqY5Tj7b7eXxFE0Xmp08c+fjTVAjYjgJmP2ydtQ6n2upnIpZKG0gu7Cz6YySFiGJ+qfWxtzcH6bB/mL4hAyBr+BrSjAnxyOk4ULTnPJqw1wMGbeyeLKhijr6SLg1cIdYo8MRaFn96EXnM0/kx94xe49YqToIxXB+AGQKJzdbZHsogfX0NCAku0AvxZhcAO7GC/J2qiyrCybsVem73ibpctXqP9cf4Z/+T93WVR21XdGuG6rWop6BOYJWcTdngQhNrHl7BkYjs4elv4sjHJ4T9kPdV0g/XiObu3qj2tfUULjL0gYgmEg69zsbr45NQGglaPherWqn0wTHHxiXFzOtucdjIOkf7GLNQLqMiIQYDOKfi+LQks48BSGetxdU8Nm9Hf5gfcEnA1bo8ZA0+HZCL1nIaWc+rLkKJGVmd4IzoMg3CNmg2BbOwsasU5wzDLqN9L0M="
}

resource "aws_vpc" "qha_vpc" {
  cidr_block = "10.0.0.0/26"
}
 
resource "aws_subnet" "qha_public" {
  vpc_id = "${aws_vpc.qha_vpc.id}"
  cidr_block = "10.0.0.0/28"
  availability_zone = "eu-west-1b"
}

resource "aws_internet_gateway" "qha_iw" {
  vpc_id = "${aws_vpc.qha_vpc.id}"
}
 
resource "aws_route_table" "qha_public_rt" {
  vpc_id = "${aws_vpc.qha_vpc.id}"
 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.qha_iw.id}"
  }
}
 
resource "aws_route_table_association" "qha_public_route_assoc" {
  subnet_id = "${aws_subnet.qha_public.id}"
  route_table_id = "${aws_route_table.qha_public_rt.id}"
}