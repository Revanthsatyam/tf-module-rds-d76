resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(local.tags, { Name = "${local.name_prefix}-subnet" })
}

resource "aws_security_group" "main" {
  name   = "${local.name_prefix}-sg"
  vpc_id = var.vpc_id
  tags   = merge(local.tags, { Name = "${local.name_prefix}-sg" })

  ingress {
    description = "RDS"
    from_port   = var.sg_port
    to_port     = var.sg_port
    protocol    = "tcp"
    cidr_blocks = var.ssh_ingress
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_rds_cluster_parameter_group" "main" {
  name        = "${local.name_prefix}-cluster-pg"
  family      = var.engine_family
  description = "${local.name_prefix}-cluster-pg"
}