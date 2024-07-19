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

resource "snowflake_grant_database_role" "granted_to_role" {
  for_each = toset(module.this.enabled ? var.granted_to_roles : [])

  database_role_name = local.database_role_name
  parent_role_name   = each.value
}

resource "snowflake_grant_database_role" "parent_database_role" {
  count = module.this.enabled && var.parent_database_role != null ? 1 : 0

  database_role_name        = local.database_role_name
  parent_database_role_name = var.parent_database_role
}

resource "snowflake_grant_database_role" "granted_to_database_roles" {
  for_each = toset(module.this.enabled ? var.granted_to_database_roles : [])

  database_role_name        = local.database_role_name
  parent_database_role_name = each.value
}

resource "snowflake_grant_database_role" "granted_database_roles" {
  for_each = toset(module.this.enabled ? var.granted_database_roles : [])

  database_role_name        = each.value
  parent_database_role_name = local.database_role_name
}

resource "snowflake_grant_privileges_to_database_role" "database_grants" {
  for_each = module.this.enabled ? local.database_grants : {}

  all_privileges     = each.value.all_privileges
  privileges         = each.value.privileges
  with_grant_option  = each.value.with_grant_option
  database_role_name = local.database_role_name

  on_database = one(snowflake_database_role.this[*].database)
}

resource "snowflake_grant_privileges_to_database_role" "schema_grants" {
  for_each = module.this.enabled ? local.schema_grants : {}

  all_privileges     = each.value.all_privileges
  privileges         = each.value.privileges
  with_grant_option  = each.value.with_grant_option
  database_role_name = local.database_role_name

  on_schema {
    all_schemas_in_database    = each.value.all_schemas_in_database == true ? one(snowflake_database_role.this[*].database) : null
    schema_name                = each.value.schema_name != null ? "\"${one(snowflake_database_role.this[*].database)}\".\"${each.value.schema_name}\"" : null
    future_schemas_in_database = each.value.future_schemas_in_database == true ? one(snowflake_database_role.this[*].database) : null
  }
}

resource "snowflake_grant_privileges_to_database_role" "schema_objects_grants" {
  for_each = module.this.enabled ? local.schema_objects_grants : {}

  all_privileges     = each.value.all_privileges
  privileges         = each.value.privileges
  with_grant_option  = each.value.with_grant_option
  database_role_name = local.database_role_name

  on_schema_object {
    object_type = each.value.object_type != null && !try(each.value.on_all, false) && !try(each.value.on_future, false) ? each.value.object_type : null
    object_name = each.value.object_name != null && !try(each.value.on_all, false) && !try(each.value.on_future, false) ? "\"${one(snowflake_database_role.this[*].database)}\".\"${each.value.schema_name}\".\"${each.value.object_name}\"" : null
    dynamic "all" {
      for_each = try(each.value.on_all, false) ? [1] : []
      content {
        object_type_plural = each.value.object_type
        in_database        = each.value.schema_name == null ? one(snowflake_database_role.this[*].database) : null
        in_schema          = each.value.schema_name != null ? "\"${one(snowflake_database_role.this[*].database)}\".\"${each.value.schema_name}\"" : null
      }
    }

    dynamic "future" {
      for_each = try(each.value.on_future, false) ? [1] : []
      content {
        object_type_plural = each.value.object_type
        in_database        = each.value.schema_name == null ? one(snowflake_database_role.this[*].database) : null
        in_schema          = each.value.schema_name != null ? "\"${one(snowflake_database_role.this[*].database)}\".\"${each.value.schema_name}\"" : null
      }
    }
  }
}
