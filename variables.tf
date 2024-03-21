variable "database_name" {
  description = "The name of the database to create the role in"
  type        = string
}

variable "comment" {
  description = "Database Role description"
  type        = string
  default     = null
}

variable "descriptor_name" {
  description = "Name of the descriptor used to form a resource name"
  type        = string
  default     = "snowflake-role"
}

variable "parent_database_role" {
  description = "Fully qualified Parent Database Role name (`DB_NAME.ROLE_NAME`), to create parent-child relationship"
  type        = string
  default     = null
}

variable "granted_database_roles" {
  description = "Database Roles granted to this role"
  type        = list(string)
  default     = []
}

variable "database_grants" {
  description = "Grants on a database level"
  type = list(object({
    all_privileges    = optional(bool)
    with_grant_option = optional(bool, false)
    privileges        = optional(list(string), null)
    database_name     = optional(string, null)
  }))
  default = []

  validation {
    condition     = alltrue([for grant in var.database_grants : (grant.privileges != null) != (grant.all_privileges == true)])
    error_message = "Variable `database_grants` fails validation - only one of `privileges` or `all_privileges` can be set."
  }
}

variable "schema_grants" {
  description = "Grants on a schema level"
  type = list(object({
    all_privileges             = optional(bool)
    with_grant_option          = optional(bool, false)
    privileges                 = optional(list(string), null)
    all_schemas_in_database    = optional(bool)
    future_schemas_in_database = optional(bool)
    schema_name                = optional(string, null)
  }))
  default = []
  validation {
    condition     = alltrue([for grant in var.schema_grants : (grant.privileges != null) != (grant.all_privileges == true)])
    error_message = "Variable `schema_grants` fails validation - only one of `privileges` or `all_privileges` can be set."
  }
  validation {
    condition = alltrue([for grant in var.schema_grants :
      sum(
        [
          grant.all_schemas_in_database != null ? 1 : 0,
          grant.future_schemas_in_database != null ? 1 : 0,
      grant.schema_name != null ? 1 : 0]) == 1
      ]
    )
    error_message = "Variable `schema_grants` fails validation - only one of `all_schemas_in_database`, `future_schemas_in_database`, or `schema_name` can be set."
  }
}

variable "schema_objects_grants" {
  description = "Grants on a schema object level"
  type = list(object({
    all_privileges    = optional(bool)
    with_grant_option = optional(bool)
    privileges        = optional(list(string))
    object_type       = optional(string)
    object_name       = optional(string)
    all = optional(object({
      object_type_plural = string
      in_database        = optional(string)
      in_schema          = optional(string)
    }))
    future = optional(object({
      object_type_plural = string
      in_database        = optional(string)
      in_schema          = optional(string)
    }))
  }))
  default = []

  validation {
    condition     = alltrue([for grant in var.schema_objects_grants : (grant.privileges != null) != (grant.all_privileges != null)])
    error_message = "Variable `schema_objects_grants` fails validation - only one of `privileges` or `all_privileges` can be set."
  }

  validation {
    condition = alltrue([for grant in var.schema_objects_grants :
      (grant.object_type != null && grant.object_name != null ? 1 : 0) +
      (grant.all != null ? 1 : 0) +
      (grant.future != null ? 1 : 0) == 1
    ])
    error_message = "Variable `schema_objects_grants` fails validation - only one of `object_type` and `object_name`, `all`, or `future` can be set."
  }

  validation {
    condition     = alltrue([for grant in var.schema_objects_grants : grant.object_name != null ? can(regex("/", grant.object_name)) : true])
    error_message = "Variable `schema_objects_grants` fails validation - `object_name` must contain '/' and have schema_name/object_name format."
  }
}
