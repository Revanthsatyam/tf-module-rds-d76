locals {
  name_prefix = "${var.env}-rds"
  tags = merge(var.tags, { Name = "tf-module-rds" }, { env = var.env })
}