variable "postgres_version" {
  type        = string
  default     = "13"
  description = "Postgres Engine Version"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  type        = number
  default     = 10
  description = "Allocated storage in GB"
}

variable "backup_retention_period" {
  type        = number
  default     = 5
  description = "The number of days that each backup is retained"
}

variable "enable_public_access" {
  type        = bool
  default     = false
  description = <<EOF
By default, the postgres cluster is not accessible to the public.
If you want to access your database, we recommend using a bastion instead.
However, this is necessary for scenarios like connecting from a Heroku app.
EOF
}

locals {
  port = 5432
}
