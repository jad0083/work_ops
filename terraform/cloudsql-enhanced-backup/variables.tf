variable "project_id" {
  description = "GCP project ID where the Cloud SQL instance and backup resources will live."
  type        = string
}

variable "region" {
  description = "Region for the Cloud SQL instance, backup vault, and backup plan. All three must match."
  type        = string
  default     = "us-central1"
}

variable "instance_name" {
  description = "Cloud SQL instance name; also used as a prefix for vault/plan/association IDs."
  type        = string
  default     = "sql-enhanced"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,97}[a-z0-9]$", var.instance_name))
    error_message = "instance_name must start with a letter, end alphanumeric, and use only lowercase letters, digits, and hyphens."
  }
}

variable "database_version" {
  description = "Cloud SQL engine version. Examples: MYSQL_8_0, POSTGRES_16, SQLSERVER_2022_STANDARD."
  type        = string
  default     = "MYSQL_8_0"
}

variable "tier" {
  description = "Machine tier. For ENTERPRISE_PLUS edition use db-perf-optimized-N-* tiers."
  type        = string
  default     = "db-custom-2-7680"
}

variable "edition" {
  description = "Cloud SQL edition. Enhanced Backups require ENTERPRISE or ENTERPRISE_PLUS."
  type        = string
  default     = "ENTERPRISE_PLUS"

  validation {
    condition     = contains(["ENTERPRISE", "ENTERPRISE_PLUS"], var.edition)
    error_message = "edition must be ENTERPRISE or ENTERPRISE_PLUS for Enhanced Backups support."
  }
}

variable "availability_type" {
  description = "ZONAL or REGIONAL. REGIONAL gives an HA configuration."
  type        = string
  default     = "REGIONAL"
}

variable "disk_size_gb" {
  description = "Initial disk size in GB."
  type        = number
  default     = 50
}

variable "deletion_protection" {
  description = "Cloud SQL deletion protection. Recommended true in production."
  type        = bool
  default     = true
}

variable "point_in_time_recovery_enabled" {
  description = "Enable PITR (binlog/WAL retention). Note: enhanced backup plan also has log_retention_days separately."
  type        = bool
  default     = true
}

variable "vault_min_retention_duration" {
  description = "Backup vault minimum enforced retention as a duration string (e.g., 2592000s = 30 days)."
  type        = string
  default     = "2592000s"
}

variable "vault_access_restriction" {
  description = "Vault access scope. WITHIN_PROJECT | WITHIN_ORGANIZATION | UNRESTRICTED | WITHIN_ORG_BUT_UNRESTRICTED_FOR_BA."
  type        = string
  default     = "WITHIN_ORGANIZATION"
}

variable "log_retention_days" {
  description = "Cloud SQL transaction log retention in the backup plan, in days."
  type        = number
  default     = 7
}

variable "daily_retention_days" {
  description = "Retention in days for the daily backup rule."
  type        = number
  default     = 30
}

variable "weekly_retention_days" {
  description = "Retention in days for the weekly backup rule."
  type        = number
  default     = 90
}

variable "monthly_retention_days" {
  description = "Retention in days for the monthly backup rule."
  type        = number
  default     = 365
}

variable "schedule_time_zone" {
  description = "IANA time zone for backup schedules."
  type        = string
  default     = "UTC"
}

variable "labels" {
  description = "Labels applied to the backup vault."
  type        = map(string)
  default     = {}
}
