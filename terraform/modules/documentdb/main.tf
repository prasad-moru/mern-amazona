// modules/documentdb/main.tf
resource "aws_docdb_subnet_group" "default" {
  name       = "${var.name_prefix}-docdb-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-docdb-subnet-group"
    }
  )
}

resource "aws_docdb_cluster_parameter_group" "default" {
  family      = "docdb4.0"
  name        = "${var.name_prefix}-docdb-param-group"
  description = "DocumentDB parameter group for ${var.name_prefix}"

  # Add any custom parameters here if needed
  # parameter {
  #   name  = "tls"
  #   value = "enabled"
  # }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-docdb-param-group"
    }
  )
}

resource "aws_docdb_cluster" "default" {
  cluster_identifier              = "${var.name_prefix}-docdb-cluster"
  engine                          = "docdb"
  master_username                 = var.master_username
  master_password                 = var.master_password
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.preferred_backup_window
  preferred_maintenance_window    = var.preferred_maintenance_window
  db_subnet_group_name            = aws_docdb_subnet_group.default.name
  vpc_security_group_ids          = [var.database_security_group_id]
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.default.name
  storage_encrypted               = true
  deletion_protection             = var.deletion_protection

  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name_prefix}-docdb-final-snapshot"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-docdb-cluster"
    }
  )
}

resource "aws_docdb_cluster_instance" "instances" {
  count              = var.instance_count
  identifier         = "${var.name_prefix}-docdb-instance-${count.index + 1}"
  cluster_identifier = aws_docdb_cluster.default.id
  instance_class     = var.instance_class

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-docdb-instance-${count.index + 1}"
    }
  )
}