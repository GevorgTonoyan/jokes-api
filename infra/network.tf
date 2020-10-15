resource "aws_security_group" "ubuntu-sg" {
  name        = "ubuntu-security-group"
  description = "Allow HTTP, HTTPS and SSH traffic"
  tags = {
    Env       = "dev"
    terraform = "true"
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [""]
  }

  ingress {
    description = "concourse"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [""]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [""]
  }

  ingress {
    description = "flask"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = [""]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "leonidas_elastic" {
  vpc      = true
  instance = aws_instance.leonidas.id
  tags = {
    Env       = "dev"
    terraform = "true"
  }
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