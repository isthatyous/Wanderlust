

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
  filter {
    name   = "image-type"
    values = ["machine"]
  }

  owners = ["099720109477"]
}


# key pair
resource "aws_key_pair" "wanderlust-key" {
  key_name   = "wanderlust-terra-key"
  public_key = file("wanderlust-terra-key.pub")
}

resource "aws_default_vpc" "wanderlust-jenkins-vpc" {
  tags = {
    Name = "Wanderlust VPC"
  }
}



resource "aws_default_security_group" "wanderlust-sg" {
  vpc_id = aws_default_vpc.wanderlust-jenkins-vpc.id


  ingress {
    description = "SSH from anywhere"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  ingress {
    description = "HTTPS from anywhere"
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "Jenkins Port"
    protocol = "tcp"
    from_port = 8080
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "SonarQube Port"
    protocol = "tcp"
    from_port = 9000
    to_port = 9000
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    description = "OWASP Port"
    protocol = "tcp"
    from_port = 8090
    to_port = 8090
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "wanderlust-sg"
    description = "Security Group for Jenkins VPC"
  }
}

# aws instance 
resource "aws_instance" "wanderlust-instance" {
  for_each = local.instance_config
  

  ami = data.aws_ami.ubuntu.id
  key_name = aws_key_pair.wanderlust-key.key_name
  vpc_security_group_ids = [aws_default_security_group.wanderlust-sg.id]
  # subnet_id = aws_subnet.wanderlust-subnet.id
  instance_type = each.value.instance_type
  user_data = each.key == "Jenkins-Slave" ? file("pipeline-setup.sh") : null
  # user_data = file("pipeline-setup.sh")

  tags = {
    Name = each.key
    Environment = "prod"

  }
  
  root_block_device {
    volume_size = each.value.volume_size
    volume_type = "gp3"
  }
}



resource "aws_eip" "wanderlust-eip-jenkins" {
  instance = aws_instance.wanderlust-instance["Jenkins-Slave"].id
  domain   = "vpc"
}


