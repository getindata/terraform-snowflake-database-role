module "snowflake_role" {
  source  = "../../"
  context = module.this.context

  name = "LOGS_DATABASE_READER"

  granted_to_users = ["JANE_SMITH", "JOHN_DOE"]

  database_grants = [
    {
      database_name = "LOGS_DB"
      privileges    = ["USAGE"]
    },
    {
      database_name = "ANALYTICS_DB"
      privileges    = ["CREATE SCHEMA", "MONITOR"]
    },
    {
      database_name  = "REPORTS_DB"
      all_privileges = true
    },
    {
      database_name = "ARCHIVE_DB"
      privileges    = ["MODIFY", "CREATE DATABASE ROLE"]
    }
  ]

  schema_grants = [
    {
      database_name              = "LOGS_DB"
      schema_name                = "BRONZE"
      privileges                 = ["USAGE"]
      all_privileges             = false
      with_grant_option          = false
      all_schemas_in_database    = false
      future_schemas_in_database = false
    },
    {
      database_name              = "LOGS_DB"
      schema_name                = "SILVER"
      privileges                 = ["CREATE TABLE", "CREATE VIEW"]
      all_privileges             = false
      with_grant_option          = true
      all_schemas_in_database    = false
      future_schemas_in_database = false
    },
    {
      database_name              = "LOGS_DB"
      schema_name                = "GOLD"
      all_privileges             = true
      with_grant_option          = false
      all_schemas_in_database    = false
      future_schemas_in_database = false
    },
    {
      database_name              = "LOGS_DB"
      all_schemas_in_database    = true
      privileges                 = ["USAGE"]
      all_privileges             = false
      with_grant_option          = false
      future_schemas_in_database = false
    },
    {
      database_name              = "LOGS_DB"
      future_schemas_in_database = true
      privileges                 = ["CREATE TABLE"]
      all_privileges             = false
      with_grant_option          = false
    }
  ]

}
