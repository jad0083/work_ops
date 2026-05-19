terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.14.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.14.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "required" {
  for_each = toset([
    "sqladmin.googleapis.com",
    "backupdr.googleapis.com",
    "servicenetworking.googleapis.com",
  ])
  service            = each.key
  disable_on_destroy = false
}

resource "random_password" "root" {
  length           = 24
  special          = true
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
  override_special = "!@#$%^&*()-_=+"
}

resource "google_sql_database_instance" "this" {
  name                = var.instance_name
  region              = var.region
  database_version    = var.database_version
  deletion_protection = var.deletion_protection
  root_password       = random_password.root.result

  settings {
    tier              = var.tier
    edition           = var.edition
    availability_type = var.availability_type
    disk_type         = "PD_SSD"
    disk_size         = var.disk_size_gb
    disk_autoresize   = true

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
      start_time                     = "02:00"
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
    }

    maintenance_window {
      day          = 7
      hour         = 4
      update_track = "stable"
    }

    ip_configuration {
      ipv4_enabled = true
    }

    insights_config {
      query_insights_enabled  = true
      record_application_tags = true
      record_client_address   = true
    }
  }

  lifecycle {
    ignore_changes = [
      settings[0].backup_configuration,
      root_password,
    ]
  }

  depends_on = [google_project_service.required]
}

resource "google_backup_dr_backup_vault" "this" {
  location                                   = var.region
  backup_vault_id                            = "${var.instance_name}-vault"
  description                                = "Enhanced backup vault for ${var.instance_name}"
  backup_minimum_enforced_retention_duration = var.vault_min_retention_duration
  access_restriction                         = var.vault_access_restriction

  labels = merge(
    var.labels,
    { instance = var.instance_name }
  )

  depends_on = [google_project_service.required]
}

resource "google_backup_dr_backup_plan" "this" {
  provider       = google-beta
  location       = var.region
  backup_plan_id = "${var.instance_name}-plan"
  resource_type  = "sqladmin.googleapis.com/Instance"
  backup_vault   = google_backup_dr_backup_vault.this.id
  description    = "Enhanced backup plan for ${var.instance_name}"

  log_retention_days = var.log_retention_days

  backup_rules {
    rule_id               = "daily"
    backup_retention_days = var.daily_retention_days
    standard_schedule {
      recurrence_type = "DAILY"
      time_zone       = var.schedule_time_zone
      backup_window {
        start_hour_of_day = 2
        end_hour_of_day   = 6
      }
    }
  }

  backup_rules {
    rule_id               = "weekly"
    backup_retention_days = var.weekly_retention_days
    standard_schedule {
      recurrence_type = "WEEKLY"
      days_of_week    = ["SUNDAY"]
      time_zone       = var.schedule_time_zone
      backup_window {
        start_hour_of_day = 3
        end_hour_of_day   = 7
      }
    }
  }

  backup_rules {
    rule_id               = "monthly"
    backup_retention_days = var.monthly_retention_days
    standard_schedule {
      recurrence_type = "MONTHLY"
      days_of_month   = [1]
      time_zone       = var.schedule_time_zone
      backup_window {
        start_hour_of_day = 4
        end_hour_of_day   = 8
      }
    }
  }
}

resource "google_backup_dr_backup_plan_association" "this" {
  provider                   = google-beta
  location                   = var.region
  backup_plan_association_id = "${var.instance_name}-bpa"
  resource_type              = "sqladmin.googleapis.com/Instance"
  resource                   = "projects/${var.project_id}/instances/${google_sql_database_instance.this.name}"
  backup_plan                = google_backup_dr_backup_plan.this.id
}
