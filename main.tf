resource "aws_key_pair" "deployer" {
  key_name   = var.key-name
  public_key = file("/home/hilmi/miro-dev-aws.pub")
}


# Creating security group to restrict/allow inbound connectivity
resource "aws_security_group" "network-security-group" {
  name        = var.network-security-group-name
  description = "Open 22,443,80,8080"

  # Define a single ingress rule to allow traffic on all specified ports
  ingress = [
    for port in [22, 80, 443, 8080, 5432] : {
      description      = "TLS from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "miro-network-all"
  }
}


# Creating Ubuntu EC2 instance
resource "aws_instance" "jenkins-instance" {
  ami             = var.ubuntu-ami
  instance_type   = var.ubuntu-instance-type
  key_name        = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.network-security-group.id]
    user_data              = templatefile("./setup_mainserver.sh", {})

  tags = {
    Name = "Main-server"
  } 
}

# Creating Ubuntu EC2 instance
resource "aws_instance" "webserver-instance-staging" {
  ami             = var.ubuntu-ami
  instance_type   = var.ubuntu-instance-type
  key_name        = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.network-security-group.id]
    user_data              = templatefile("./setup_webserver.sh", {})

  tags = {
    Name = "web-server-staging"
  } 
}

# Creating Ubuntu EC2 instance
resource "aws_instance" "webserver-instance-productio" {
  ami             = var.ubuntu-ami
  instance_type   = var.ubuntu-instance-type
  key_name        = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.network-security-group.id]
    user_data              = templatefile("./setup_webserver.sh", {})

  tags = {
    Name = "web-server-production"
  } 
}