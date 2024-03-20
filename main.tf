module "role_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.this.context

  delimiter           = coalesce(module.this.context.delimiter, "_")
  regex_replace_chars = coalesce(module.this.context.regex_replace_chars, "/[^_a-zA-Z0-9]/")
  label_value_case    = coalesce(module.this.context.label_value_case, "upper")
}

resource "snowflake_database_role" "this" {
  count = module.this.enabled ? 1 : 0

  database = snowflake_database_role.this.database
  name     = local.name_from_descriptor
  comment  = var.comment
}

resource "snowflake_grant_database_role" "parent_database_role" {
  count = module.this.enabled && var.parent_database_role != null ? 1 : 0

  database_role_name        = local.database_role_name
  parent_database_role_name = var.parent_database_role
}

resource "snowflake_grant_database_role" "granted_database_roles" {
  for_each = toset(module.this.enabled ? var.granted_database_roles : [])

  database_role_name        = each.value
  parent_database_role_name = local.database_role_name
}

resource "snowflake_grant_privileges_to_database_role" "database_grants" {
  for_each = module.this.enabled ? toset(var.database_grants) : {}

  all_privileges     = each.value.all_privileges
  privileges         = each.value.privileges
  with_grant_option  = each.value.with_grant_option
  database_role_name = local.database_role_name

  on_database = snowflake_database_role.this.database
}

resource "snowflake_grant_privileges_to_database_role" "schema_grants" {
  for_each = module.this.enabled ? var.schema_grants : {}

  all_privileges     = each.value.all_privileges
  privileges         = each.value.privileges
  with_grant_option  = each.value.with_grant_option
  database_role_name = local.database_role_name

  on_schema = {
    all_schemas_in_database    = each.value.all_schemas_in_database != null ? snowflake_database_role.this.database : null
    schema_name                = each.value.schema_name != null ? "\"${snowflake_database_role.this.database}\".\"${each.value.schema_name}\"" : null
    future_schemas_in_database = each.value.future_schemas_in_database != null ? snowflake_database_role.this.database : null
  }
}


resource "snowflake_grant_privileges_to_database_role" "schema_objects_grants" {
  for_each = module.this.enabled ? var.schema_objects_grants : {}

  all_privileges     = each.value.all_privileges
  privileges         = each.value.privileges
  with_grant_option  = each.value.with_grant_option
  database_role_name = local.database_role_name

  on_schema_object {
    dynamic "object_type" {
      for_each = each.value.object_type != null ? [1] : []
      content {
        object_type = each.value.object_type
        object_name = each.value.object_name # "\"${snowflake_database_role.db_role.database}\".\"my_schema\".\"my_view\"" # note this is a fully qualified name!
      }
    }

    dynamic "all" {
      for_each = each.value.all != null ? [1] : []
      content {
        object_type_plural = each.value.all.object_type_plural
        in_database        = each.value.all.in_database
        in_schema          = each.value.all.in_schema # "\"${snowflake_database_role.db_role.database}\".\"my_schema\"" # note this is a fully qualified name!
      }
    }

    dynamic "future" {
      for_each = each.value.future != null ? [1] : []
      content {
        object_type_plural = each.value.future.object_type_plural
        in_database        = each.value.future.in_database
        in_schema          = each.value.future.in_schema # "\"${snowflake_database_role.db_role.database}\".\"my_schema\"" # note this is a fully qualified name!
      }
    }
  }
}

# TODO: check if in_database can be used with conunction with in_schema
# TODO: Refactor all_schemas_in_database = snowflake_database_role.db_role.database to use snowflake_database_role to use
