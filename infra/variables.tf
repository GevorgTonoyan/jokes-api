variable "key_name" {
  type    = string
  default = "ubuntu"
}

variable "private_key" {
  default = "/home/gev/.ssh/ubuntu"
}

variable "public_key" {
  default = "/home/gev/.ssh/ubuntu.pub"
}

variable "ami" {
  type    = string
  default = "ami-092391a11f8aa4b7b"
}
