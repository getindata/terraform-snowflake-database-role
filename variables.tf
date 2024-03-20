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
    all_privileges    = optional(bool, false)
    with_grant_option = optional(bool, false)
    privileges        = optional(list(string), null)
    database_name     = string
  }))
  default = []

  validation {
    condition     = alltrue([for grant in var.database_grants : (grant.privileges != null) != (grant.all_privileges != null)])
    error_message = "Variable `database_grants` fails validation - only one of `privileges` or `all_privileges` can be set."
  }
}

variable "schema_grants" {
  description = "Grants on a schema level"
  type = list(object({
    all_privileges             = optional(bool, false)
    with_grant_option          = optional(bool, false)
    privileges                 = optional(list(string), null)
    all_schemas_in_database    = optional(string, null)
    future_schemas_in_database = optional(string, null)
    schema_name                = string
  }))
  default = []
  validation {
    condition     = alltrue([for grant in var.schema_grants : (grant.privileges != null) != (grant.all_privileges != null)])
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
    all_privileges    = optional(bool, false)
    with_grant_option = optional(bool, false)
    privileges        = optional(list(string), null)
    object_type       = optional(string, null)
    object_name       = optional(string, null)
    all               = optional(bool, false)
    future            = optional(bool, false)
  }))
  default = []

  validation {
    condition     = alltrue([for grant in var.schema_objects_grants : (grant.privileges != null) != (grant.all_privileges != null)])
    error_message = "Variable `schema_objects_grants` fails validation - only one of `privileges` or `all_privileges` can be set."
  }

  validation {
    condition     = alltrue([for grant in var.schema_objects_grants : (grant.all != null) != (grant.future != null)])
    error_message = "Variable `schema_objects_grants` fails validation - only one of `all` or `future` can be set."
  }
}
