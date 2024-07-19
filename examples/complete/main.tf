resource "snowflake_database" "this" {
  name = "TEST_DB"
}

resource "snowflake_schema" "this" {
  database = snowflake_database.this.name
  name     = "BRONZE"
}

resource "snowflake_table" "table_1" {
  database = snowflake_schema.this.database
  schema   = snowflake_schema.this.name
  name     = "TEST_TABLE_1"

  column {
    name     = "identity"
    type     = "NUMBER(38,0)"
    nullable = true

    identity {
      start_num = 1
      step_num  = 3
    }
  }
}

resource "snowflake_table" "table_2" {
  database = snowflake_schema.this.database
  schema   = snowflake_schema.this.name
  name     = "TEST_TABLE_2"

  column {
    name     = "identity"
    type     = "NUMBER(38,0)"
    nullable = true

    identity {
      start_num = 1
      step_num  = 3
    }
  }
}

resource "snowflake_role" "role_1" {
  name = "ROLE_1"
}

resource "snowflake_role" "role_2" {
  name = "ROLE_2"
}
resource "snowflake_database_role" "db_role_1" {
  database = snowflake_database.this.name
  name     = "DB_ROLE_1"
}

resource "snowflake_database_role" "db_role_2" {
  database = snowflake_database.this.name
  name     = "DB_ROLE_2"
}

resource "snowflake_database_role" "db_role_3" {
  database = snowflake_database.this.name
  name     = "DB_ROLE_3"
}

module "snowflake_database_role" {
  source  = "../../"
  context = module.this.context

  database_name = snowflake_database.this.name
  name          = "TEST_DB_ROLE"

  granted_to_roles = [
    snowflake_role.role_1.name,
    snowflake_role.role_2.name
  ]

  granted_to_database_roles = [
    "${snowflake_database.this.name}.${snowflake_database_role.db_role_1.name}"
  ]

  granted_database_roles = [
    "${snowflake_database.this.name}.${snowflake_database_role.db_role_2.name}",
    "${snowflake_database.this.name}.${snowflake_database_role.db_role_3.name}"
  ]

  database_grants = {
    privileges = ["USAGE", "CREATE SCHEMA"]
  }


  schema_grants = [
    {
      schema_name = snowflake_schema.this.name
      privileges  = ["USAGE"]
    },
    {
      future_schemas_in_database = true
      all_schemas_in_database    = true
      privileges                 = ["USAGE"]
    },
  ]

  schema_objects_grants = {
    "TABLE" = [
      {
        privileges  = ["SELECT"]
        object_name = snowflake_table.table_1.name
        schema_name = snowflake_schema.this.name
      },
      {
        all_privileges = true
        object_name    = snowflake_table.table_2.name
        schema_name    = snowflake_schema.this.name
      }
    ]
    "ALERT" = [
      {
        all_privileges = true
        on_future      = true
        on_all         = true
      }
    ]
  }
}
