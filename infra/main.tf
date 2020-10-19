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
}

module "web_provisioner" {
  source = "./terraform-null-ansible"

  arguments = ["--user=ubuntu"]
  envs      = ["host=${aws_eip.leonidas_elastic.public_ip}"]
  playbook  = "./ansible/master.yml"
  dry_run   = false
}

# Export Terraform variable values to an Ansible var_file
resource "local_file" "tf_ansible_vars_file_new" {
  depends_on = [aws_eip.leonidas_elastic]
  content    = <<-DOC
    host: ${aws_eip.leonidas_elastic.public_ip}
    ansible_private_key_file: /home/gev/.ssh/ubuntu
    external: "http://${aws_eip.leonidas_elastic.public_ip}:8080"
    
    DOC
  filename   = "./ansible/vars.yml"
}