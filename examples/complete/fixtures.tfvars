context_templates = {
  snowflake-database-role        = "{{.environment}}_{{.name}}"
  snowflake-schema-database-role = "{{.environment}}_{{.schema}}_{{.name}}"
}
