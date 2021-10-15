provider "aws" {
 
  region   = "eu-west-1"
  profile  = "log-prd-backup"
 
}
 
resource "aws_instance" "qha-test" {
 
  ami         = "ami-0f396f98a2cc57548"
  instance_type = "t2.micro"
  key_name= "qha-keypair-test"
  vpc_security_group_ids = [aws_security_group.qha-test-sg.id]
 
  tags = {
    Name = "QHA-TEST"
  } 
}

resource "aws_security_group" "qha-test-sg" {
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

resource "aws_eip" "qha-eip-test" {
  vpc = true
}

resource "aws_eip_association" "qha_eip_assoc" {
  instance_id   = aws_instance.qha-test.id
  allocation_id = aws_eip.qha-eip-test.id
}

resource "aws_key_pair" "qha-keypair-test" {
  key_name   = "qha-keypair-test"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCtByjOVWLZMp/rcFxFCttce5HiWVgOHleDboql6kvW4BG+jclvgTH54HORtSYhqY5Tj7b7eXxFE0Xmp08c+fjTVAjYjgJmP2ydtQ6n2upnIpZKG0gu7Cz6YySFiGJ+qfWxtzcH6bB/mL4hAyBr+BrSjAnxyOk4ULTnPJqw1wMGbeyeLKhijr6SLg1cIdYo8MRaFn96EXnM0/kx94xe49YqToIxXB+AGQKJzdbZHsogfX0NCAku0AvxZhcAO7GC/J2qiyrCybsVem73ibpctXqP9cf4Z/+T93WVR21XdGuG6rWop6BOYJWcTdngQhNrHl7BkYjs4elv4sjHJ4T9kPdV0g/XiObu3qj2tfUULjL0gYgmEg69zsbr45NQGglaPherWqn0wTHHxiXFzOtucdjIOkf7GLNQLqMiIQYDOKfi+LQks48BSGetxdU8Nm9Hf5gfcEnA1bo8ZA0+HZCL1nIaWc+rLkKJGVmd4IzoMg3CNmg2BbOwsasU5wzDLqN9L0M="
}