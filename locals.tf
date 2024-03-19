locals {
  # Get a name from the descriptor. If not available, use default naming convention.
  # Trim and replace function are used to avoid bare delimiters on both ends of the name and situation of adjacent delimiters.
  name_from_descriptor = module.role_label.enabled ? trim(replace(
    lookup(module.role_label.descriptors, var.descriptor_name, module.role_label.id), "/${module.role_label.delimiter}${module.role_label.delimiter}+/", module.role_label.delimiter
  ), module.role_label.delimiter) : null

  database_role_name = "\"${one(snowflake_database_role.this[*].database)}\".\"${one(snowflake_database_role.this[*].name)}\""

  schema_grants = merge([for grant in var.schema_grants : {
    for key, value in { "schema_name" = grant.dynamic_table_name, "on_all" = grant.on_all, "on_future" = grant.on_future } :
    "${coalesce(grant.schema_name, "all")}" => {
      schema_name    = key == "schema_name" ? value : null
      on_future      = key == "on_future" ? value : false
      on_all         = key == "on_all" ? value : false
      privileges     = grant.privileges
      all_privileges = grant.all_privileges
    } if(key == "schema_name" && value != null) || value == true
  }]...)


  table_grants = merge([for grant in var.table_grants : {
    for key, value in { "table_name" = grant.dynamic_table_name, "on_all" = grant.on_all, "on_future" = grant.on_future } :
    "${coalesce(grant.schema_name, "all")}/${key == "table_name" ? value : key}" => {
      schema_name        = grant.schema_name
      dynamic_table_name = key == "table_name" ? value : null
      on_future          = key == "on_future" ? value : false
      on_all             = key == "on_all" ? value : false
      privileges         = grant.privileges
      all_privileges     = grant.all_privileges
    } if(key == "table_name" && value != null) || value == true
  }]...)


  external_table_grants = merge([for grant in var.external_table_grants : {
    for key, value in { "external_table_name" = grant.dynamic_table_name, "on_all" = grant.on_all, "on_future" = grant.on_future } :
    "${coalesce(grant.schema_name, "all")}/${key == "external_table_name" ? value : key}" => {
      schema_name        = grant.schema_name
      dynamic_table_name = key == "external_table_name" ? value : null
      on_future          = key == "on_future" ? value : false
      on_all             = var.database_grants.on_all
      on_future          = var.database_grants.on_future
      all_privileges     = var.database_grants.all_privileges
      privileges         = var.database_grants.privileges
      on_all             = key == "on_all" ? value : false
      privileges         = grant.privileges
      all_privileges     = grant.all_privileges
    } if(key == "external_table_name" && value != null) || value == true
  }]...)

  view_grants = merge([for grant in var.view_grants : {
    for key, value in { "view_name" = grant.view_name, "on_all" = grant.on_all, "on_future" = grant.on_future } :
    "${coalesce(grant.schema_name, "all")}/${key == "view_name" ? value : key}" => {
      schema_name        = grant.schema_name
      dynamic_table_name = key == "view_name" ? value : null
      on_future          = key == "on_future" ? value : false
      on_all             = key == "on_all" ? value : false
      privileges         = grant.privileges
      all_privileges     = grant.all_privileges
    } if(key == "view_name" && value != null) || value == true
  }]...)

  dynamic_table_grants = merge([for grant in var.dynamic_table_grants : {
    for key, value in { "dynamic_table_name" = grant.dynamic_table_name, "on_all" = grant.on_all, "on_future" = grant.on_future } :
    "${coalesce(grant.schema_name, "all")}/${key == "dynamic_table_name" ? value : key}" => {
      schema_name        = grant.schema_name
      dynamic_table_name = key == "dynamic_table_name" ? value : null
      on_future          = key == "on_future" ? value : false
      on_all             = key == "on_all" ? value : false
      privileges         = grant.privileges
      all_privileges     = grant.all_privileges
    } if(key == "dynamic_table_name" && value != null) || value == true
  }]...)
}
