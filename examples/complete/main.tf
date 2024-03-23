module "snowflake_database_role" {
  source  = "../../"
  context = module.this.context

  database_name = "PS_PLAYGROUND"
  comment       = "Database role for PS_PLAYGROUND"
  name          = "PS_DB_ROLE"


  # parent_database_role = "PS_DB_ROLE_1"
  # granted_database_roles = [
  #   "PS_DB_ROLE_2",
  #   "PS_DB_ROLE_3"
  # ]
  # database_grants = [
  #   {
  #     privileges = ["USAGE", "CREATE SCHEMA"]
  #   },
  # ]

  # schema_grants = [
  #   {
  #     schema_name = "BRONZE"
  #     privileges  = ["USAGE"]
  #   },
  #   {
  #     future_schemas_in_database = true
  #     privileges                 = ["USAGE"]
  #   },
  #   {
  #     all_schemas_in_database = true
  #     privileges              = ["USAGE"]
  #   },
  # ]

  schema_objects_grants = [
    {
      object_type = "VIEWS"
      privileges  = ["SELECT"]
      on_all      = true
      in_schema   = "BRONZE"
    },
    {
      object_type = "TABLE"
      privileges  = ["SELECT"]
      object_name = "TEST_TABLE"
      in_schema   = "BRONZE"
    },
    {
      object_type = "ICEBERG TABLES"
      privileges  = ["SELECT"]
      on_future   = true
      in_schema   = "BRONZE"
    }
  ]

}
