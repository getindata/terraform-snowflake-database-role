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

  schema_objects_grants = {
    "TABLE" = [
      {
        privileges  = ["SELECT"]
        object_name = "TEST_TABLE"
        schema_name = "BRONZE"
      },
      {
        all_privileges = true
        object_name    = "TEST_TABLE_2"
        schema_name    = "BRONZE"
      }
    ]
    "ICEBERG TABLE" = [
      {
        privileges = ["SELECT"]
        on_future  = true
        on_all     = true
      },
      {
        privileges  = ["SELECT"]
        object_name = "TEST_ICEBERG_TABLE"
        schema_name = "BRONZE"
      }
    ]
  }
}


