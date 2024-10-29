# Terraform Config file (main.tf). This has provider block (AWS) and config for provisioning one EC2 instance resource.  

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.27"
    }
  }

  required_version = ">=0.14"
}
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Define tags locally
locals {
  default_tags = merge(var.default_tags, { "env" = var.env })
}

# Create a new VPC 
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = merge(
    local.default_tags, {
      Name = "${var.prefix}-VPC"
    }
  )
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index] # so these two subnets are in idfferent AZ. us-east1a use-east-1b
  tags = merge(
    local.default_tags, {
      Name = "${var.prefix}-private-subnet-${count.index + 1}"
    }
  )
}

# Route table for private subnets doesn't point to any Gateway at this stage
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id  
  tags = {
    Name = "${var.prefix}-RT-private-subnets"
  }
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private_route_table_association" {
  count          = length(aws_subnet.private_subnet)
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}

