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
  tags        = merge(local.tags, { Name = "${local.name_prefix}-pg" })
}

resource "aws_rds_cluster" "main" {
  cluster_identifier              = "${local.name_prefix}-cluster"
  engine                          = var.engine
  engine_version                  = var.engine_version
  db_subnet_group_name            = aws_db_subnet_group.main.name
  vpc_security_group_ids          = [aws_security_group.main.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.name
  database_name                   = "mydb"
  master_username                 = "foo"
  master_password                 = "must_be_eight_characters"
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.preferred_backup_window
  skip_final_snapshot             = var.skip_final_snapshot
  tags                            = merge(local.tags, { Name = "${local.name_prefix}-cluster" })
}