
# Public key

#resource "aws_key_pair" "keypair" {
 # key_name   = "keypair"
 # public_key = ""
#}
# security group for bastion host

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["223.236.102.17/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}



# security group fo private instance

resource "aws_security_group" "allow_http" {
  name        = "allow_http,ssh"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/16"]
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

#Bastion Host

resource "aws_instance" "Bastion" {
  ami                    = "ami-01216e7612243e0ef"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id              = "${element(module.vpc.public_subnets, 0)}"
  iam_instance_profile   = aws_iam_instance_profile.test_profile.name
  #key_name              = aws_key_pair.keypair.key_name
  key_name               = "project1"
}

#private instance

resource "aws_instance" "demo1" {
  ami                    = "ami-01216e7612243e0ef"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  subnet_id              = "${element(module.vpc.private_subnets, 0)}"
  iam_instance_profile   = aws_iam_instance_profile.test_profile.name
  key_name               = "project1"
  user_data = <<-EOT
#!/bin/bash
# Use this for your user data (script from top to bottom)
# install httpd (Linux 2 version)
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
EOT
}


resource "aws_instance" "demo2" {
  ami                    = "ami-01216e7612243e0ef"
  instance_type          = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  subnet_id              = "${element(module.vpc.private_subnets, 1)}"
  key_name               = "project1"
  user_data = <<-EOT
#!/bin/bash
# Use this for your user data (script from top to bottom)
# install httpd (Linux 2 version)
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
EOT
}