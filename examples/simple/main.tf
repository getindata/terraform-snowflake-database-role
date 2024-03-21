module "snowflake_database_role" {
  source = "../../"

  database_name = "PS_PLAYGROUND"
  comment       = "Database role for PS_PLAYGROUND"
  name          = "PS_DB_ROLE"
}
