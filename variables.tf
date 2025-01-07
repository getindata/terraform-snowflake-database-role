variable "name" {
  description = "Name of the resource"
  type        = string
}

variable "database_name" {
  description = "The name of the database to create the role in"
  type        = string
}

variable "comment" {
  description = "Database Role description"
  type        = string
  default     = null
}

variable "parent_database_role" {
  description = "DEPRECATED variable - please use `granted_to_database_roles` instead"
  type        = string
  default     = null
}

variable "granted_to_roles" {
  description = "List of Snowflake Account Roles to grant this role to"
  type        = list(string)
  default     = []
}

variable "granted_to_shares" {
  description = "List of Snowflake Shares to grant this role to"
  type        = list(string)
  default     = []
}

variable "granted_to_database_roles" {
  description = "Fully qualified Parent Database Role name (`DB_NAME.ROLE_NAME`), to create parent-child relationship"
  type        = list(string)
  default     = []
}

variable "granted_database_roles" {
  description = "Database Roles granted to this role"
  type        = list(string)
  default     = []
}
variable "database_grants" {
  description = "Grants on a database level"
  type = object({
    all_privileges    = optional(bool)
    with_grant_option = optional(bool, false)
    privileges        = optional(list(string), null)
  })
  default = {}

  validation {
    condition     = var.database_grants == {} ? (var.database_grants.privileges != null) != (var.database_grants.all_privileges == true) : true
    error_message = "Variable `database_grants` fails validation - only one of `privileges` or `all_privileges` can be set."
  }
}

variable "schema_grants" {
  description = "Grants on a schema level"
  type = list(object({
    all_privileges             = optional(bool)
    with_grant_option          = optional(bool, false)
    privileges                 = optional(list(string), null)
    all_schemas_in_database    = optional(bool, false)
    future_schemas_in_database = optional(bool, false)
    schema_name                = optional(string, null)
  }))
  default = []
  validation {
    condition     = alltrue([for grant in var.schema_grants : (grant.privileges != null) != (grant.all_privileges == true)])
    error_message = "Variable `schema_grants` fails validation - only one of `privileges` or `all_privileges` can be set."
  }
}

variable "schema_objects_grants" {
  description = <<EOF
  Grants on a schema object level

  Example usage:

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

  Note: If you don't provide a schema_name, the grants will be created for all objects of that type in the database.
        You can find a list of all object types [here](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_privileges_to_database_role#object_type)
  EOF
  type = map(list(object({
    all_privileges    = optional(bool)
    with_grant_option = optional(bool)
    privileges        = optional(list(string))
    object_name       = optional(string)
    on_all            = optional(bool, false)
    schema_name       = optional(string)
    on_future         = optional(bool, false)
  })))
  default = {}

  validation {
    condition     = alltrue([for object_type, grants in var.schema_objects_grants : alltrue([for grant in grants : (grant.privileges != null) != (grant.all_privileges != null)])])
    error_message = "Variable `schema_objects_grants` fails validation - only one of `privileges` or `all_privileges` can be set."
  }

  validation {
    condition = alltrue([for object_type, grants in var.schema_objects_grants : alltrue([for grant in grants :
      !(grant.object_name != null && (grant.on_all == true || grant.on_future == true))
    ])])
    error_message = "Variable `schema_objects_grants` fails validation - `object_name` cannot be set with `on_all` or `on_future`."
  }
}

variable "name_scheme" {
  description = <<EOT
  Naming scheme configuration for the resource. This configuration is used to generate names using context provider:
    - `properties` - list of properties to use when creating the name - is superseded by `var.context_templates`
    - `delimiter` - delimited used to create the name from `properties` - is superseded by `var.context_templates`
    - `context_template_name` - name of the context template used to create the name
    - `replace_chars_regex` - regex to use for replacing characters in property-values created by the provider - any characters that match the regex will be removed from the name
    - `extra_values` - map of extra label-value pairs, used to create a name
    - `uppercase` - convert name to uppercase
  EOT
  type = object({
    properties            = optional(list(string), ["environment", "name"])
    delimiter             = optional(string, "_")
    context_template_name = optional(string, "snowflake-role")
    replace_chars_regex   = optional(string, "[^a-zA-Z0-9_]")
    extra_values          = optional(map(string))
    uppercase             = optional(bool, true)
  })
  default = {}
}

variable "context_templates" {
  description = "Map of context templates used for naming conventions - this variable supersedes `naming_scheme.properties` and `naming_scheme.delimiter` configuration"
  type        = map(string)
  default     = {}
}
