provider "aws" {
 
  region   = "eu-west-1"
  profile  = "log-prd-backup"
 
}
 
resource "aws_instance" "qha-test" {
 
  ami         = "ami-0f396f98a2cc57548"
  instance_type = "t2.micro"
 
 
}