data "context_label" "this" {
  delimiter  = local.context_template == null ? var.name_scheme.delimiter : null
  properties = local.context_template == null ? var.name_scheme.properties : null
  template   = local.context_template

  replace_chars_regex = var.name_scheme.replace_chars_regex

  values = merge(
    var.name_scheme.extra_values,
    { name = var.name }
  )
}

resource "snowflake_database_role" "this" {
  database = var.database_name
  name     = var.name_scheme.uppercase ? upper(data.context_label.this.rendered) : data.context_label.this.rendered
  comment  = var.comment
}
moved {
  from = snowflake_database_role.this[0]
  to   = snowflake_database_role.this
}

resource "snowflake_grant_database_role" "granted_to_role" {
  for_each = toset(var.granted_to_roles)

  database_role_name = snowflake_database_role.this.fully_qualified_name
  parent_role_name   = each.value

  depends_on = [snowflake_database_role.this]
}

resource "snowflake_grant_database_role" "granted_to_share" {
  for_each = toset(var.granted_to_shares)

  database_role_name = snowflake_database_role.this.fully_qualified_name
  share_name         = each.value

  depends_on = [snowflake_database_role.this]
}

resource "snowflake_grant_database_role" "parent_database_role" {
  count = var.parent_database_role != null ? 1 : 0

  database_role_name        = snowflake_database_role.this.fully_qualified_name
  parent_database_role_name = var.parent_database_role

  depends_on = [snowflake_database_role.this]
}

resource "snowflake_grant_database_role" "granted_to_database_roles" {
  for_each = toset(var.granted_to_database_roles)

  database_role_name        = snowflake_database_role.this.fully_qualified_name
  parent_database_role_name = each.value

  depends_on = [snowflake_database_role.this]
}

resource "snowflake_grant_database_role" "granted_database_roles" {
  for_each = toset(var.granted_database_roles)

  database_role_name        = each.value
  parent_database_role_name = snowflake_database_role.this.fully_qualified_name

  depends_on = [snowflake_database_role.this]
}

resource "snowflake_grant_privileges_to_database_role" "database_grants" {
  for_each = local.database_grants

  all_privileges     = each.value.all_privileges
  privileges         = each.value.privileges
  with_grant_option  = each.value.with_grant_option
  database_role_name = snowflake_database_role.this.fully_qualified_name

  on_database = snowflake_database_role.this.database

  depends_on = [snowflake_database_role.this]
}

resource "snowflake_grant_privileges_to_database_role" "schema_grants" {
  for_each = local.schema_grants

  all_privileges     = each.value.all_privileges
  privileges         = each.value.privileges
  with_grant_option  = each.value.with_grant_option
  database_role_name = snowflake_database_role.this.fully_qualified_name

  on_schema {
    all_schemas_in_database    = each.value.all_schemas_in_database == true ? snowflake_database_role.this.database : null
    schema_name                = each.value.schema_name != null ? "\"${snowflake_database_role.this.database}\".\"${each.value.schema_name}\"" : null
    future_schemas_in_database = each.value.future_schemas_in_database == true ? snowflake_database_role.this.database : null
  }

  depends_on = [snowflake_grant_privileges_to_database_role.database_grants]
}

resource "snowflake_grant_privileges_to_database_role" "schema_objects_grants" {
  for_each = local.schema_objects_grants

  all_privileges     = each.value.all_privileges
  privileges         = each.value.privileges
  with_grant_option  = each.value.with_grant_option
  database_role_name = snowflake_database_role.this.fully_qualified_name

  on_schema_object {
    object_type = each.value.object_type != null && !try(each.value.on_all, false) && !try(each.value.on_future, false) ? each.value.object_type : null
    object_name = each.value.object_name != null && !try(each.value.on_all, false) && !try(each.value.on_future, false) ? "\"${snowflake_database_role.this.database}\".\"${each.value.schema_name}\".\"${each.value.object_name}\"" : null
    dynamic "all" {
      for_each = try(each.value.on_all, false) ? [1] : []
      content {
        object_type_plural = each.value.object_type
        in_database        = each.value.schema_name == null ? snowflake_database_role.this.database : null
        in_schema          = each.value.schema_name != null ? "\"${snowflake_database_role.this.database}\".\"${each.value.schema_name}\"" : null
      }
    }

    dynamic "future" {
      for_each = try(each.value.on_future, false) ? [1] : []
      content {
        object_type_plural = each.value.object_type
        in_database        = each.value.schema_name == null ? snowflake_database_role.this.database : null
        in_schema          = each.value.schema_name != null ? "\"${snowflake_database_role.this.database}\".\"${each.value.schema_name}\"" : null
      }
    }
  }

  depends_on = [snowflake_grant_privileges_to_database_role.schema_grants]
}
