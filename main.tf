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

  database = var.database_name
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

  privilege          = each.value.privileges
  all_privileges     = each.value.all_privileges
  database_role_name = local.database_role_name

  on_database = var.database_name
}

resource "snowflake_grant_privileges_to_database_role" "schema_grants" {
  for_each = module.this.enabled ? local.schema_grants : {}

  database_role_name = local.database_role_name
  all_privileges     = each.value.all_privileges
  privileges         = each.value.privileges

  on_schema = {
    all_schemas_in_database    = each.value.on_all ? var.database_name : null
    schema_name                = each.value.schema_name != null ? "${var.database_name}.${each.value.schema_name}" : null
    future_schemas_in_database = each.value.on_future ? var.database_name : null
  }
}

resource "snowflake_table_grant" "this" {
  for_each = module.this.enabled ? local.table_grants : {}

  enable_multiple_grants = each.value.enable_multiple_grants
  database_name          = each.value.database_name
  schema_name            = each.value.schema_name
  table_name             = each.value.table_name
  privilege              = each.value.privilege
  on_future              = each.value.on_future
  on_all                 = each.value.on_all
  roles                  = [one(snowflake_role.this[*].name)]
}
resource "snowflake_grant_privileges_to_database_role" "table_grants" {
  for_each = module.this.enabled ? local.table_grants : {}

  privilege          = each.value.privileges
  all_privileges     = each.value.all_privileges
  database_role_name = local.database_role_name

  on_schema_object {
    object_type = "TABLE"
    object_name = each.value.table_name != null ? "${var.database_name}.${each.value.schema_name}.${each.value.table_name}" : null

    dynamic "all" {
      for_each = each.value.on_all ? [1] : []
      content {
        object_type_plural = "TABLES"
        in_schema          = "${var.database_name}.${each.value.schema_name}"
      }
    }

    dynamic "future" {
      for_each = each.value.on_future ? [1] : []
      content {
        object_type_plural = "TABLES"
        in_schema          = "${var.database_name}.${each.value.schema_name}"
      }

    }
  }
}


resource "snowflake_external_table_grant" "this" {
  for_each = module.this.enabled ? local.external_table_grants : {}

  enable_multiple_grants = each.value.enable_multiple_grants
  database_name          = each.value.database_name
  schema_name            = each.value.schema_name
  external_table_name    = each.value.external_table_name
  privilege              = each.value.privilege
  on_future              = each.value.on_future
  on_all                 = each.value.on_all
  roles                  = [one(snowflake_role.this[*].name)]
}

resource "snowflake_view_grant" "this" {
  for_each = module.this.enabled ? local.view_grants : {}

  enable_multiple_grants = each.value.enable_multiple_grants
  database_name          = each.value.database_name
  schema_name            = each.value.schema_name
  view_name              = each.value.view_name
  privilege              = each.value.privilege
  on_future              = each.value.on_future
  on_all                 = each.value.on_all
  roles                  = [one(snowflake_role.this[*].name)]
}

resource "snowflake_account_grant" "this" {
  for_each = toset(module.this.enabled ? var.account_grants : [])

  enable_multiple_grants = var.enable_multiple_grants
  privilege              = each.value
  roles                  = [one(snowflake_role.this[*].name)]

  with_grant_option = false
}

resource "snowflake_grant_privileges_to_role" "dynamic_table" {
  for_each = module.this.enabled ? local.dynamic_table_grants : {}

  privileges     = each.value.privileges
  all_privileges = each.value.all_privileges
  role_name      = one(snowflake_role.this[*].name)

  on_schema_object {

    object_type = each.value.dynamic_table_name != null ? "DYNAMIC TABLE" : null
    object_name = each.value.dynamic_table_name != null ? join(".", [each.value.database_name, each.value.schema_name, each.value.dynamic_table_name]) : null

    dynamic "future" {
      for_each = each.value.on_future ? [1] : []
      content {
        object_type_plural = "DYNAMIC TABLES"
        in_database        = each.value.schema_name != null ? null : each.value.database_name
        in_schema          = each.value.schema_name != null ? join(".", [each.value.database_name, each.value.schema_name]) : null
      }
    }

    dynamic "all" {
      for_each = each.value.on_all ? [1] : []
      content {
        object_type_plural = "DYNAMIC TABLES"
        in_database        = each.value.schema_name != null ? null : each.value.database_name
        in_schema          = each.value.schema_name != null ? join(".", [each.value.database_name, each.value.schema_name]) : null
      }
    }
  }
}
