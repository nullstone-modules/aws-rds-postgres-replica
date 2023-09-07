resource "aws_db_instance" "this" {
  #bridgecrew:skip=CKV_AWS_157: "Ensure that RDS instances have Multi-AZ enabled"
  identifier                  = local.resource_name
  replicate_source_db         = data.ns_connection.postgres.db_instance_id
  instance_class              = var.instance_class
  skip_final_snapshot = true
  publicly_accessible = true

  engine                      = "postgres"
  engine_version              = var.postgres_version
  allow_major_version_upgrade = true
  auto_minor_version_upgrade  = true
  allocated_storage           = var.allocated_storage
  storage_encrypted           = true
  storage_type                = "gp2"
  port                        = local.port
  vpc_security_group_ids      = [aws_security_group.this.id]

  tags                        = local.tags

  // final_snapshot_identifier is unique to when an instance is launched
  // This prevents repeated launch+destroy from creating the same final snapshot and erroring
  // Changes to the name are ignored so it doesn't keep invalidating the instance
  final_snapshot_identifier = "${local.resource_name}-${replace(timestamp(), ":", "-")}"

  backup_retention_period = var.backup_retention_period
  backup_window           = "02:00-03:00"
}
