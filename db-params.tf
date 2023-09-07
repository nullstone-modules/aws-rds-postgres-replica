locals {
  enforce_ssl_parameter = var.enforce_ssl ? tomap({ "rds.force_ssl" = 1 }) : tomap({})
  default_db_parameters = tomap({})
  db_parameters         = merge(local.default_db_parameters, var.custom_postgres_params, local.enforce_ssl_parameter)
}

locals {
  // Can only contain alphanumeric and hyphen characters
  param_group_name = "${local.resource_name}-postgres${replace(var.postgres_version, ".", "-")}"
}

resource "aws_db_parameter_group" "this" {
  name_prefix = local.param_group_name
  family      = "postgres${var.postgres_version}"
  tags        = local.tags
  description = "Postgres for ${local.block_name} (${local.env_name})"

  // When postgres version changes, we need to create a new one that attaches to the db
  //   because we can't destroy a parameter group that's in use
  lifecycle {
    create_before_destroy = true
  }

  dynamic "parameter" {
    for_each = local.db_parameters

    content {
      name         = parameter.key
      value        = parameter.value
      apply_method = contains(local.dynamic_param_names, parameter.key) ? "immediate" : "pending-reboot"
    }
  }
}

locals {
  // This contains a list of param names that you can change without an rds reboot
  // This acts as a whitelist to allow immediate setting of a parameter
  dynamic_param_names = [
    "application_name",
    "array_nulls",
    "authentication_timeout",
    "autovacuum",
    "autovacuum_analyze_scale_factor",
    "autovacuum_analyze_threshold",
    "autovacuum_naptime",
    "autovacuum_vacuum_cost_delay",
    "autovacuum_vacuum_cost_limit",
    "autovacuum_vacuum_scale_factor",
    "autovacuum_vacuum_threshold",
    "backslash_quote",
    "bgwriter_delay",
    "bgwriter_lru_maxpages",
    "bgwriter_lru_multiplier",
    "bytea_output",
    "check_function_bodies",
    "checkpoint_completion_target",
    "checkpoint_segments",
    "checkpoint_timeout",
    "checkpoint_warning",
    "client_encoding",
    "client_min_messages",
    "commit_delay",
    "commit_siblings",
    "constraint_exclusion",
    "cpu_index_tuple_cost",
    "cpu_operator_cost",
    "cpu_tuple_cost",
    "cursor_tuple_fraction",
    "datestyle",
    "deadlock_timeout",
    "debug_pretty_print",
    "debug_print_parse",
    "debug_print_plan",
    "debug_print_rewritten",
    "default_statistics_target",
    "default_tablespace",
    "default_transaction_deferrable",
    "default_transaction_isolation",
    "default_transaction_read_only",
    "default_with_oids",
    "effective_cache_size",
    "effective_io_concurrency",
    "enable_bitmapscan",
    "enable_hashagg",
    "enable_hashjoin",
    "enable_indexscan",
    "enable_material",
    "enable_mergejoin",
    "enable_nestloop",
    "enable_seqscan",
    "enable_sort",
    "enable_tidscan",
    "escape_string_warning",
    "extra_float_digits",
    "from_collapse_limit",
    "fsync",
    "full_page_writes",
    "geqo",
    "geqo_effort",
    "geqo_generations",
    "geqo_pool_size",
    "geqo_seed",
    "geqo_selection_bias",
    "geqo_threshold",
    "gin_fuzzy_search_limit",
    "hot_standby_feedback",
    "intervalstyle",
    "join_collapse_limit",
    "lc_messages",
    "lc_monetary",
    "lc_numeric",
    "lc_time",
    "log_autovacuum_min_duration",
    "log_checkpoints",
    "log_connections",
    "log_disconnections",
    "log_duration",
    "log_error_verbosity",
    "log_executor_stats",
    "log_filename",
    "log_hostname",
    "log_lock_waits",
    "log_min_duration_statement",
    "log_min_error_statement",
    "log_min_messages",
    "log_parser_stats",
    "log_planner_stats",
    "log_rotation_age",
    "log_rotation_size",
    "log_statement",
    "log_statement_stats",
    "log_temp_files",
    "maintenance_work_mem",
    "max_stack_depth",
    "max_standby_archive_delay",
    "max_standby_streaming_delay",
    "max_wal_size",
    "min_wal_size",
    "quote_all_identifiers",
    "random_page_cost",
    "rds.adaptive_autovacuum",
    "rds.log_retention_period",
    "search_path",
    "seq_page_cost",
    "session_replication_role",
    "sql_inheritance",
    "ssl_renegotiation_limit",
    "standard_conforming_strings",
    "statement_timeout",
    "synchronize_seqscans",
    "synchronous_commit",
    "tcp_keepalives_count",
    "tcp_keepalives_idle",
    "tcp_keepalives_interval",
    "temp_buffers",
    "temp_tablespaces",
    "timezone",
    "track_activities",
    "track_counts",
    "track_functions",
    "track_io_timing",
    "transaction_deferrable",
    "transaction_isolation",
    "transaction_read_only",
    "transform_null_equals",
    "update_process_title",
    "vacuum_cost_delay",
    "vacuum_cost_limit",
    "vacuum_cost_page_dirty",
    "vacuum_cost_page_hit",
    "vacuum_cost_page_miss",
    "vacuum_defer_cleanup_age",
    "vacuum_freeze_min_age",
    "vacuum_freeze_table_age",
    "wal_writer_delay",
    "work_mem",
    "xmlbinary",
    "xmloption"
  ]
}