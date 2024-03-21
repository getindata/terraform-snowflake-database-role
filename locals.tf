locals {
  # Get a name from the descriptor. If not available, use default naming convention.
  # Trim and replace function are used to avoid bare delimiters on both ends of the name and situation of adjacent delimiters.
  name_from_descriptor = module.role_label.enabled ? trim(replace(
    lookup(module.role_label.descriptors, var.descriptor_name, module.role_label.id), "/${module.role_label.delimiter}${module.role_label.delimiter}+/", module.role_label.delimiter
  ), module.role_label.delimiter) : null

  database_role_name = "\"${one(snowflake_database_role.this[*].database)}\".\"${one(snowflake_database_role.this[*].name)}\""

  database_grants = { for database_grant in var.database_grants : "${one(snowflake_database_role.this[*].database)}_${one(snowflake_database_role.this[*].name)}_${database_grant.all_privileges == true ? "ALL" : join("_", database_grant.privileges)}" => database_grant }

  schema_grants = { for schema_grant in var.schema_grants : "${one(snowflake_database_role.this[*].database)}_${one(snowflake_database_role.this[*].name)}_${schema_grant.schema_name != null ? schema_grant.schema_name : "ALL_SCHEMAS"}_${schema_grant.all_privileges == true ? "ALL" : join("_", schema_grant.privileges)}" => schema_grant }

  schema_objects_grants = {
    for schema_objects_grant in var.schema_objects_grants :
    "${one(snowflake_database_role.this[*].database)}_${one(snowflake_database_role.this[*].name)}${
      schema_objects_grant.object_type != null && schema_objects_grant.object_name != null ?
      "_${schema_objects_grant.object_type}_${schema_objects_grant.object_name}_${schema_objects_grant.all_privileges == true ? "ALL" : join("_", schema_objects_grant.privileges)}"
      : ""
      }${
      schema_objects_grant.all != null ?
      "_ALL_${schema_objects_grant.all.object_type_plural}${schema_objects_grant.all.in_schema != null ? "_${schema_objects_grant.all.in_schema}_${schema_objects_grant.all_privileges == true ? "ALL" : join("_", schema_objects_grant.privileges)}" : ""}"
      : ""
      }${
      schema_objects_grant.future != null ?
      "_FUTURE_${schema_objects_grant.future.object_type_plural}${schema_objects_grant.future.in_schema != null ? "_${schema_objects_grant.future.in_schema}_${schema_objects_grant.all_privileges == true ? "ALL" : join("_", schema_objects_grant.privileges)}" : ""}"
      : ""
    }" => schema_objects_grant
  }
}
