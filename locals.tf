locals {
  context_template = lookup(var.context_templates, var.name_scheme.context_template_name, null)

  database_grants = var.database_grants.all_privileges == null && var.database_grants.privileges == null ? {} : {
    var.database_grants.all_privileges == true ? "ALL" : "CUSTOM" = var.database_grants
  }

  schema_grants = {
    for index, schema_grant in flatten([
      for grant in var.schema_grants : grant.future_schemas_in_database && grant.all_schemas_in_database ? [
        merge(
          grant,
          {
            future_schemas_in_database = true,
            all_schemas_in_database    = false
          }
        ),
        merge(
          grant,
          {
            future_schemas_in_database = false,
            all_schemas_in_database    = true
          }
        )
      ] : [grant]
    ]) :
    "${schema_grant.schema_name != null ? schema_grant.schema_name :
      schema_grant.all_schemas_in_database != false ? "ALL_SCHEMAS" :
      schema_grant.future_schemas_in_database != false ? "FUTURE_SCHEMAS" : ""
    }_${schema_grant.all_privileges == true ? "ALL" : "CUSTOM"}_${index}" => schema_grant
  }
  schema_objects_grants = {
    for index, grant in flatten([
      for object_type, grants in var.schema_objects_grants : [
        for grant in grants :
        grant.on_all && grant.on_future ? [
          merge(
            grant,
            {
              object_type = "${object_type}S",
              on_future   = true,
              on_all      = false
            }
          ),
          merge(
            grant,
            {
              object_type = "${object_type}S",
              on_future   = false,
              on_all      = true
            }
          )
          ] : [
          merge(
            grant,
            {
              object_type = grant.on_all || grant.on_future ? "${object_type}S" : object_type
            }
          )
        ]
      ]
      ]) : "${
      grant.object_type != null && grant.object_name != null ?
      "_${grant.object_type}_${grant.object_name}_${grant.all_privileges == true ? "ALL" : "CUSTOM"}"
      : ""
      }${
      grant.on_all != null && grant.on_all ?
      "_ALL_${grant.object_type}${grant.schema_name != null ? "_${grant.schema_name}_${grant.all_privileges == true ? "ALL" : "CUSTOM"}" : ""}"
      : ""
      }${
      grant.on_future != null && grant.on_future ?
      "_FUTURE_${grant.object_type}${grant.schema_name != null ? "_${grant.schema_name}_${grant.all_privileges == true ? "ALL" : "CUSTOM"}" : ""}"
      : ""
    }" => grant
  }
}
