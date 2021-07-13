provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "instance" {
  ami = "ami-0dc2d3e4c0f9ebd18"
  instance_type = "t2.micro"
  key_name = "aws_key"
  vpc_security_group_ids = [aws_security_group.allow_ports.id]
  user_data = <<-EOF
              #!/bin/bash
              yum install java-1.8.0-openjdk.x86_64 -y
              wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.50/bin/apache-tomcat-9.0.50.tar.gz
              tar xvfz apache-tomcat-9.0.50.tar.gz
              cd apache-tomcat-9.0.50/bin
              ./startup.sh
              EOF
  subnet_id = "aws_subnet.Public_sub1.id"
}

resource "aws_eip" "my-eip" {
  instance = "${aws_instance.instance.id}"
  vpc      = true
}

resource "aws_security_group" "allow_ports" {
  name = "allow_pors"
  vpc_id = "aws_vpc.myvpc.id"
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
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
 }
resource "aws_subnet" "Public_sub1" {
  cidr_block = "10.0.0.0/24"
  vpc_id = "${aws_vpc.myvpc.id}"
}
resource "aws_subnet" "public_sub2" {
  cidr_block = "10.0.1.0/24"
  vpc_id = "${aws_vpc.myvpc.id}"
}
resource "aws_subnet" "private_sub1" {
  cidr_block = "10.0.2.0/24"
  vpc_id = "${aws_vpc.myvpc.id}"
}
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.myvpc.id}"

  tags = {
    Name = "mygw"
  }
}
resource "aws_route_table" "RTFP" {
  vpc_id = "${aws_vpc.myvpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "bhavan-route"
  }
}

resource "aws_route_table_association" "subass1" {
  subnet_id      = "${aws_subnet.Public_sub1.id}"
  route_table_id = "${aws_route_table.RTFP.id}"
}

output "movpc" {
  value = "${aws_vpc.myvpc.id}"
}

output "mosub" {
  value = "${aws_subnet.Public_sub1.id}"
}



