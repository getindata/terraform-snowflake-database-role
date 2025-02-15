output "name" {
  description = "Name of the database role"
  value       = snowflake_database_role.this.name
}

output "fully_qualified_name" {
  description = "Name of the database role in fully qualified format (\"DB_NAME\".\"ROLE_NAME\")"
  value       = snowflake_database_role.this.fully_qualified_name
}
