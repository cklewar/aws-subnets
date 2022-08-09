module "aws_vpc" {
  source             = "./modules/aws/vpc"
  aws_az_name        = "us-east-1a"
  aws_region         = "us-east-1"
  aws_vpc_cidr_block = "192.168.0.0/16"
  aws_vpc_name       = "myVPC"
  custom_tags        = {
    Name  = "my_vpc"
    Owner = "c.klewar@f5.com"
  }
}

variable "aws_vpc_subnets" {
  type = list(object({
    name                    = string
    map_public_ip_on_launch = bool
    cidr_block              = string
    availability_zone       = string
  }))
  default = [
    {
      name                    = "my_subnet_A"
      map_public_ip_on_launch = true
      cidr_block              = "192.168.0.0/24"
      availability_zone       = "us-west-2a"
    },
    {
      name                    = "my_subnetB"
      map_public_ip_on_launch = true
      cidr_block              = "192.169.0.0/24"
      availability_zone       = "us-west-2a"
    }
  ]
}

provider "aws" {
  region = "us-west-2"
  alias  = "default"
}

module "aws_subnet" {
  for_each                        = {for k, v in var.aws_vpc_subnets :  k => v}
  source                          = "./modules/aws/subnet"
  aws_az_name                     = each.value.availability_zone
  aws_subnet_name                 = each.value.name
  aws_vpc_id                      = module.aws_vpc.aws_vpc_id
  aws_vpc_map_public_ip_on_launch = each.value.map_public_ip_on_launch
  subnet_cidr_block               = each.value.cidr_block
  aws_vpc_subnets                 = []
  custom_tags                     = {
    Name  = "my_vpc"
    Owner = "c.klewar@f5.com"
  }

  providers = {
    aws = aws.default
  }

}