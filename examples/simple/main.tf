module "snowflake_database_role" {
  source = "../../"

  database_name = "PLAYGROUND_DB"
  comment       = "Database role for PLAYGROUND_DB"
  name          = "EXAMPLE_DB_ROLE"
}
