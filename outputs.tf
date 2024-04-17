output "name" {
  description = "Name of the database role"
  value       = one(snowflake_database_role.this[*].name)
}

output "name_fully_qualified" {
  description = "Name of the database role in fully qualified format (\"DB_NAME\".\"ROLE_NAME\")"
  value       = local.database_role_name
}
