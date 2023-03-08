data "aws_ami" "nixos-22_05" {
  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "name"
    values = ["NixOS-22.05.*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  most_recent = true
  owners      = ["080433136561"]
}

resource "aws_key_pair" "key" {
  key_name   = local.name
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "webserver" {
  ami                         = data.aws_ami.nixos-22_05.id
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key.id
  subnet_id                   = aws_subnet.server.id
  vpc_security_group_ids      = [aws_security_group.webserver.id]

  root_block_device {
    volume_size = 40
  }

  tags = {
    Name = "webserver"
  }
}

resource "aws_security_group" "webserver" {
  name        = "${local.name}-webserver"
  description = "Allow HTTP and SSH to the host"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "${local.name}-webserver"
  }
}

output "webserver" {
  value = aws_instance.webserver.public_ip
}
