resource "snowflake_database" "this" {
  name = "TEST_DB"
}

resource "snowflake_schema" "this" {
  database = snowflake_database.this.name
  name     = "BRONZE"
}

module "snowflake_database_role" {
  source = "../../"

  database_name = snowflake_database.this.name
  name          = "TEST_DB_ROLE"


  schema_grants = [
    {
      future_schemas_in_database = true
      all_schemas_in_database    = true
      all_privileges             = true
    },
  ]

  schema_objects_grants = {
    "TABLE" = [
      {
        all_privileges = true
        on_future      = true
        on_all         = true
        schema_name    = snowflake_schema.this.name
      }
    ]
  }
}
