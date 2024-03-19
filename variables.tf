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
  type = object({
    all_privileges = optional(bool, false)
    privileges     = optional(list(string), null)
  })
  default = {}
}

variable "schema_grants" {
  description = "Grants on a schema level"
  type = list(object({
    schema_name    = optional(string)
    on_all         = optional(bool)
    on_future      = optional(bool)
    all_privileges = optional(bool)
    privileges     = optional(list(string), null)
  }))
  default = []
  validation {
    condition     = alltrue([for grant in var.schema_grants : !anytrue([grant.privileges == null && grant.all_privileges == null, grant.privileges != null && grant.all_privileges != null])])
    error_message = "Variable `schema_grants` fails validation - only one of `privileges` or `all_privileges` can be set."
  }
  validation {
    condition     = alltrue([for grant in var.schema_grants : !alltrue([grant.schema_name != null, grant.on_future || grant.on_all])])
    error_message = "Variable `schema_grants` fails validation - when `schema_name` is set, `on_future` and `on_all` have to be false / not set."
  }
}

variable "table_grants" {
  description = "Grants on a table level"
  type = list(object({
    database_name  = string
    schema_name    = string
    table_name     = optional(string)
    on_future      = optional(bool)
    on_all         = optional(bool)
    all_privileges = optional(bool)
    privileges     = optional(list(string), null)
  }))
  default = []
  validation {
    condition     = alltrue([for grant in var.table_grants : !anytrue([grant.privileges == null && grant.all_privileges == null, grant.privileges != null && grant.all_privileges != null])])
    error_message = "Variable `table_grants` fails validation - only one of `privileges` or `all_privileges` can be set."
  }
  validation {
    condition     = alltrue([for grant in var.table_grants : !alltrue([grant.table_name != null, grant.on_future || grant.on_all])])
    error_message = "Variable `table_grants` fails validation - when `table_name` is set, `on_future` and `on_all` have to be false / not set."
  }
}

variable "external_table_grants" {
  description = "Grants on a external table level"
  type = list(object({
    database_name       = string
    schema_name         = string
    external_table_name = optional(string)
    on_future           = optional(bool)
    on_all              = optional(bool)
    all_privileges      = optional(bool)
    privileges          = optional(list(string), null)
  }))
  default = []
  validation {
    condition     = alltrue([for grant in var.external_table_grants : !anytrue([grant.privileges == null && grant.all_privileges == null, grant.privileges != null && grant.all_privileges != null])])
    error_message = "Variable `external_table_grants` fails validation - only one of `privileges` or `all_privileges` can be set."
  }
  validation {
    condition     = alltrue([for grant in var.external_table_grants : !alltrue([grant.external_table_name != null, grant.on_future || grant.on_all])])
    error_message = "Variable `external_table_grants` fails validation - when `external_table_name` is set, `on_future` and `on_all` have to be false / not set."
  }
}

variable "view_grants" {
  description = "Grants on a view level"
  type = list(object({
    database_name  = string
    schema_name    = string
    view_name      = optional(string)
    on_future      = optional(bool)
    on_all         = optional(bool)
    all_privileges = optional(bool)
    privileges     = optional(list(string), null)
  }))
  default = []
  validation {
    condition     = alltrue([for grant in var.view_grants : !anytrue([grant.privileges == null && grant.all_privileges == null, grant.privileges != null && grant.all_privileges != null])])
    error_message = "Variable `view_grants` fails validation - only one of `privileges` or `all_privileges` can be set."
  }
  validation {
    condition     = alltrue([for grant in var.view_grants : !alltrue([grant.view_name != null, grant.on_future || grant.on_all])])
    error_message = "Variable `view_grants` fails validation - when `view_name` is set, `on_future` and `on_all` have to be false / not set."
  }
}

variable "dynamic_table_grants" {
  description = "Grants on a dynamic_table level"
  type = list(object({
    database_name      = string
    schema_name        = optional(string)
    dynamic_table_name = optional(string)
    on_future          = optional(bool, false)
    on_all             = optional(bool, false)
    all_privileges     = optional(bool)
    privileges         = optional(list(string), null)
  }))
  default = []
  validation {
    condition     = alltrue([for grant in var.dynamic_table_grants : !anytrue([grant.privileges == null && grant.all_privileges == null, grant.privileges != null && grant.all_privileges != null])])
    error_message = "Variable `dynamic_table_grants` fails validation - only one of `privileges` or `all_privileges` can be set."
  }
  validation {
    condition     = alltrue([for grant in var.dynamic_table_grants : !alltrue([grant.dynamic_table_name != null, grant.on_future || grant.on_all])])
    error_message = "Variable `dynamic_table_grants` fails validation - when `dynamic_table_name` is set, `on_future` and `on_all` have to be false / not set."
  }
}

variable "descriptor_name" {
  description = "Name of the descriptor used to form a resource name"
  type        = string
  default     = "snowflake-database-role"
}
