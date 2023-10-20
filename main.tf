# configure aws provider
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
}


resource "aws_vpc" "Dep5_1_VPC" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "Dep5_1_VPC"
  }
}

output "vpc_id" {
  value = aws_vpc.Dep5_1_VPC.id
}



#create subnets
resource "aws_subnet" "Dep5_1_pubsuba" {
  vpc_id     = aws_vpc.Dep5_1_VPC.id
  availability_zone = "${var.region}a"
  cidr_block = var.Dep5_1_pubsuba_cidr
  map_public_ip_on_launch = true

  //subnet config

  tags = {
    Name = "Dep5_1_pubsuba"
    vpc : "Dep5_1_VPC"
    az : "${var.region}a"
  }
}

output "pub_subneta_id" {
  value = aws_subnet.Dep5_1_pubsuba.id
}

resource "aws_subnet" "Dep5_1_pubsubb" {
  vpc_id     = aws_vpc.Dep5_1_VPC.id
  availability_zone = "${var.region}b"
  cidr_block = var.Dep5_1_pubsubb_cidr
  map_public_ip_on_launch = true

  //subnet config

  tags = {
    Name = "Dep5_1_pubsubb"
    vpc : "Dep5_1_VPC"
    az : "${var.region}b"
  }
}

output "pub_subnetb_id" {
  value = aws_subnet.Dep5_1_pubsubb.id
}

#create route table
resource "aws_route_table" "Dep5_1_rt" {
  vpc_id = aws_vpc.Dep5_1_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.deploy5_1_igw.id
  }

  tags = {
    Name : "Dep5_1_rt"
    vpc : "Dep5_1_VPC"
  }
}

#create route table association
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.Dep5_1_pubsuba.id
  route_table_id = aws_route_table.Dep5_1_rt.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.Dep5_1_pubsubb.id
  route_table_id = aws_route_table.Dep5_1_rt.id
}

#create internet gateway
resource "aws_internet_gateway" "deploy5_1_igw" {
  vpc_id = aws_vpc.Dep5_1_VPC.id

  // igw config

  tags = {
    Name = "deploy5_1_igw"
  }

}




 #create instance
resource "aws_instance" "D5_1_Jenkins_server" {

  ami = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.terraform_dep5.id]
  subnet_id = aws_subnet.Dep5_1_pubsuba.id
  associate_public_ip_address = true
  key_name = var.key_name

  user_data = "${file("jenkins.sh")}"

  tags = {
    Name : "D5_1_Jenkins_server"
    vpc : "Dep5_1_VPC"
    az : "${var.region}a"
  }
}


 #create instance
resource "aws_instance" "D5_1_Jenkins_agent_server" {

  ami = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.terraform_dep5.id]
  subnet_id = aws_subnet.Dep5_1_pubsuba.id 
  associate_public_ip_address = true
  key_name = var.key_name 
   
  user_data = "${file("software.sh")}"

  tags = {
    Name : "D5_1_Jenkins_agent_server"
    vpc : "Dep5_1_VPC"
    az : "${var.region}a"
  }
}  


 #create instance
resource "aws_instance" "Dep5_1_webapp_server" {

  ami = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.terraform_dep5.id]
  subnet_id = aws_subnet.Dep5_1_pubsub.id 
  associate_public_ip_address = true
  key_name = var.key_name 
   
  user_data = "${file("software.sh")}"

  tags = {
    Name : "Dep5_1_webapp_server"
    vpc : "Dep5_1_VPC"
    az : "${var.region}b"
  }
}  

# create security group

resource "aws_security_group" "Dep5_1_sg" {
  name        = "Dep5_1_sg"
  description = "open ssh traffic"
  vpc_id = aws_vpc.Dep5_1_VPC.id

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

  ingress {
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" : "Dep5_1_sg"
    "Terraform" : "true"
  }

}

output "D5_1_Jenkins_server_ip" {
  value = aws_instance.D5_1_Jenkins_server.public_ip
}

output "D5_1_Jenkins_agent_server_ip" {
  value = aws_instance.D5_1_Jenkins_agent_server.public_ip
}

output "Dep5_1_webapp_server_ip" {
  value = aws_instance.Dep5_1_webapp_server.public_ip
}
