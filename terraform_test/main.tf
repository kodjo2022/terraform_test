# Provider
provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
}

# Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnet_cidr_block
  availability_zone = "${var.aws_region}a"
}

# Private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_subnet_cidr_block
  availability_zone = "${var.aws_region}a"
}

# Security group
resource "aws_security_group" "instance_sg" {
  name_prefix = "instance_sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Elastic IP
resource "aws_eip" "eip" {
  vpc = true
}

# EFS file system
resource "aws_efs_file_system" "efs" {
}

# EFS mount target
resource "aws_efs_mount_target" "efs_mount_target" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.instance_sg.id]
}

# EC2 instance
resource "aws_instance" "instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true
  key_name = "my-key.pem"

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "testkey.perm"
    host        = aws_eip.eip.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y amazon-efs-utils",
      "sudo mkdir /data",
      "sudo mkdir /data/test",
      "sudo mount -t efs -o tls ${aws_efs_mount_target.efs_mount_target.dns_name}:/ /data/test",
      "echo '${aws_efs_mount_target.efs_mount_target.dns_name}:/ /data/test efs tls,_netdev 0 0' | sudo tee -a /etc/fstab"
    ]
  }
}
