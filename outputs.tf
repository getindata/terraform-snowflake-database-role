output "name" {
  description = "Name of the database role"
  value       = one(snowflake_database_role.this[*].name)
}
