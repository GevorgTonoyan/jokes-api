provider "aws" {
  region = "eu-central-1"
}

resource "aws_key_pair" "ubuntu" {
  key_name   = var.key_name
  public_key = file(var.public_key)
  tags = {
    env       = "dev"
    terraform = "true"
  }
}


resource "aws_instance" "leonidas" {
  key_name      = var.key_name
  ami           = var.ami
  instance_type = "t2.micro"
  tags = {
    env       = "dev"
    terraform = "true"
  }

  vpc_security_group_ids = [
    aws_security_group.ubuntu-sg.id
  ]
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp2"
    volume_size = 30
  }

  # provisioner "remote-exec" {
  #   inline = ["echo 'Hello World'"]

  #   connection {
  #     type        = "ssh"
  #     user        = "ubuntu"
  #     private_key = file(var.private_key)
  #     host        = self.public_ip
  #   }
  # }

  # provisioner "local-exec" {
  #   command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i '${self.public_ip},' --private-key=/home/gev/.ssh/ubuntu master.yml"
  # }
}


module "web_provisioner" {
  source = "./terraform-null-ansible"

  arguments = ["--user=ubuntu"]
  envs      = ["host=${aws_eip.leonidas_elastic.public_ip}"]
  playbook  = "./ansible/master.yml"
  dry_run   = false
}

