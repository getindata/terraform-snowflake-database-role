module "snowflake_database_role" {
  source  = "../../"
  context = module.this.context

  database_name = "PS_PLAYGROUND"
  comment       = "Database role for PS_PLAYGROUND"
  name          = "PS_DB_ROLE"


  database_grants = [
    {
      privileges = ["USAGE", "CREATE SCHEMA"]
    },
  ]

  schema_grants = [
    {
      schema_name = "BRONZE"
      privileges  = ["USAGE"]
    },
    {
      future_schemas_in_database = true
      privileges                 = ["USAGE"]
    },
    {
      all_schemas_in_database = true
      privileges              = ["USAGE"]
    },
  ]

  schema_objects_grants = [
    {
      privileges = ["SELECT"]
      future = {
        object_type_plural = "TABLES"
        in_schema          = "BRONZE"
      }
    },
    {
      privileges  = ["SELECT"]
      object_type = "TABLE"
      object_name = "BRONZE/TEST_TABLE"
    },
    {
      privileges = ["SELECT"]
      future = {
        object_type_plural = "ICEBERG TABLES"
        in_schema          = "BRONZE"
      }
    }
  ]

}
