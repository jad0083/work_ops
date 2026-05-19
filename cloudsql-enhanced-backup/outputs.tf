output "instance_name" {
  description = "Cloud SQL instance name."
  value       = google_sql_database_instance.this.name
}

output "instance_connection_name" {
  description = "Connection name in the form PROJECT:REGION:INSTANCE — used by the Cloud SQL Auth Proxy."
  value       = google_sql_database_instance.this.connection_name
}

output "instance_private_ip" {
  description = "Private IP, if configured."
  value       = google_sql_database_instance.this.private_ip_address
}

output "instance_public_ip" {
  description = "Public IP, if configured."
  value       = google_sql_database_instance.this.public_ip_address
}

output "root_password" {
  description = "Generated root password. Sensitive — retrieve once and store in a secret manager."
  value       = random_password.root.result
  sensitive   = true
}

output "backup_vault_id" {
  description = "Backup-and-DR vault ID."
  value       = google_backup_dr_backup_vault.this.id
}

output "backup_plan_id" {
  description = "Backup plan ID."
  value       = google_backup_dr_backup_plan.this.id
}

output "backup_plan_association_id" {
  description = "Backup plan association ID — proves the plan is bound to the instance."
  value       = google_backup_dr_backup_plan_association.this.id
}
