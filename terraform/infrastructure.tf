# All the code that related to the infrastructure will in this file
# so we do not need to touch the main.tf file.


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

#================================
# SSH Key creation
#================================
resource "aws_key_pair" "deployer" {
  key_name   = "ansible-user"
  public_key = "${file("/home/chamoo/.ssh/ansible-user.pub")}"
}

#=================================
# AWS SG for the webserver_access
#=================================
resource "aws_security_group" "webserver_access" {
        name = "webserver_access"
        description = "allow ssh and http"

        ingress {
                from_port = 80
                to_port = 80
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }

        ingress {
                from_port = 22
                to_port = 22
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }

        egress {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
}

#=======================
# EC2 instance creation
#=======================
resource "aws_instance" "server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name = "ansible-user"
  security_groups = ["${aws_security_group.webserver_access.name}"]

  tags = {
    Name = "app_server"
  }
}

