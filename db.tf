resource "aws_db_instance" "this" {
  #bridgecrew:skip=CKV_AWS_157: "Ensure that RDS instances have Multi-AZ enabled"
  identifier                  = local.resource_name
  replicate_source_db         = data.ns_connection.postgres.db_instance_id
  db_subnet_group_name        = aws_db_subnet_group.this.name
  parameter_group_name        = aws_db_parameter_group.this.name
  engine                      = "postgres"
  engine_version              = var.postgres_version
  allow_major_version_upgrade = true
  auto_minor_version_upgrade  = true
  instance_class              = var.instance_class
  multi_az                    = var.high_availability
  allocated_storage           = var.allocated_storage
  storage_encrypted           = true
  storage_type                = "gp2"
  port                        = local.port
  vpc_security_group_ids      = [aws_security_group.this.id]
  tags                        = local.tags
  publicly_accessible         = var.enable_public_access

  iam_database_authentication_enabled = true

  apply_immediately = true

  // final_snapshot_identifier is unique to when an instance is launched
  // This prevents repeated launch+destroy from creating the same final snapshot and erroring
  // Changes to the name are ignored so it doesn't keep invalidating the instance
  final_snapshot_identifier = "${local.resource_name}-${replace(timestamp(), ":", "-")}"

  backup_retention_period = var.backup_retention_period
  backup_window           = "02:00-03:00"

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  monitoring_interval             = 5
  monitoring_role_arn             = aws_iam_role.monitoring.arn

  lifecycle {
    ignore_changes = [username, final_snapshot_identifier]
  }

  depends_on = [aws_cloudwatch_log_group.this, aws_cloudwatch_log_group.upgrade]
}

resource "aws_db_subnet_group" "this" {
  name        = local.resource_name
  description = "Postgres db subnet group for postgres cluster"
  subnet_ids  = var.enable_public_access ? local.public_subnet_ids : local.private_subnet_ids
  tags        = local.tags
}

resource "aws_iam_role" "monitoring" {
  name               = "${local.resource_name}-monitoring"
  assume_role_policy = data.aws_iam_policy_document.monitoring_assume.json
  tags               = local.tags
}

data "aws_iam_policy_document" "monitoring_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }

    // These conditions prevent the confused deputy problem
    // See https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.Enabling.html#USER_Monitoring.OS.confused-deputy
    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:rds:${data.aws_region.this.name}:${data.aws_caller_identity.current.account_id}:db:${local.resource_name}"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role_policy_attachment" "monitoring" {
  role       = aws_iam_role.monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
