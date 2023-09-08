resource "aws_db_instance" "this" {
  #bridgecrew:skip=CKV_AWS_157: "Ensure that RDS instances have Multi-AZ enabled"
  identifier                  = local.resource_name
  replicate_source_db         = data.ns_connection.postgres.outputs.db_instance_id
  parameter_group_name        = aws_db_parameter_group.this.name
  allow_major_version_upgrade = true
  auto_minor_version_upgrade  = true
  instance_class              = var.instance_class
  multi_az                    = var.high_availability
  storage_encrypted           = true
  storage_type                = "gp2"
  port                        = local.port
  vpc_security_group_ids      = [data.ns_connection.postgres.outputs.db_security_group_id]
  tags                        = local.tags

  iam_database_authentication_enabled = true

  apply_immediately = true

  // this must be set to null in order to delete this replica
  final_snapshot_identifier = null

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  monitoring_interval             = 5
  monitoring_role_arn             = aws_iam_role.monitoring.arn

  lifecycle {
    ignore_changes = [username, final_snapshot_identifier]
  }

  depends_on = [aws_cloudwatch_log_group.this, aws_cloudwatch_log_group.upgrade]
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
