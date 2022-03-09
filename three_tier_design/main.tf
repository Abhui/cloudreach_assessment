data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["abhi"]

  filter {
    name = "name"

    values = [
      "ami-00399ec92321828f5",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon"
    ]
  }
}

variable "region" {
  description = "The AWS region to deploy to"
  default = "ap-southeast-1"
}

variable "name" {
  description = "The name of the deployment"
  default = ""
}

variable "public_key" {
  default = ""
}
