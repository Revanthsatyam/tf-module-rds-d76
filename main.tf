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
  database_name                   = data.aws_ssm_parameter.database_name.value
  master_username                 = data.aws_ssm_parameter.master_username.value
  master_password                 = data.aws_ssm_parameter.master_password.value
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.preferred_backup_window
  skip_final_snapshot             = var.skip_final_snapshot
  storage_encrypted               = true
  kms_key_id                      = var.kms_key
  tags                            = merge(local.tags, { Name = "${local.name_prefix}-cluster" })
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = var.instance_count
  identifier         = "${local.name_prefix}-cluster-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = var.instance_class
  engine             = var.engine
  engine_version     = var.engine_version
}