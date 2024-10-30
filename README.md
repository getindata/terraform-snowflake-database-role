# Snowflake Database Role Terraform Module

![Snowflake](https://img.shields.io/badge/-SNOWFLAKE-249edc?style=for-the-badge&logo=snowflake&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)

![License](https://badgen.net/github/license/getindata/terraform-snowflake-database-role/)
![Release](https://badgen.net/github/release/getindata/terraform-snowflake-database-role/)

<p align="center">
  <img height="150" src="https://getindata.com/img/logo.svg">
  <h3 align="center">We help companies turn their data into assets</h3>
</p>

---

Terraform module for managing Snowflake Database roles.

- Creates Snowflake database role with specific privileges on database and schemas.
- Allows granting of privileges on future schemas in a database.
- Allows granting of privileges on all existing schemas in a database.
- Allows granting of privileges on specific schema objects like tables.
- Supports granting of all privileges or specific ones based on the configuration.
- Can be used to create a hierarchy of roles by assigning parent roles.
- Can be used to grant roles to other roles.

## USAGE

```terraform
resource "snowflake_database" "this" {
  name = "TEST_DB"
}

resource "snowflake_schema" "this" {
  database = snowflake_database.this.name
  name     = "BRONZE"
}

module "snowflake_database_role" {
  source = "../../"

  database_name = snowflake_database.this.name
  name          = "TEST_DB_ROLE"


  schema_grants = [
    {
      future_schemas_in_database = true
      all_schemas_in_database    = true
      all_privileges             = true
    },
  ]

  schema_objects_grants = {
    "TABLE" = [
      {
        all_privileges = true
        on_future      = true
        on_all         = true
        schema_name    = snowflake_schema.this.name
      }
    ]
  }
}
```

## EXAMPLES

- [Simple](examples/simple) - Basic usage of the module
- [Complete](examples/complete) - Advanced usage of the module
<!-- BEGIN_TF_DOCS -->




## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_comment"></a> [comment](#input\_comment) | Database Role description | `string` | `null` | no |
| <a name="input_context_templates"></a> [context\_templates](#input\_context\_templates) | Map of context templates used for naming conventions - this variable supersedes `naming_scheme.properties` and `naming_scheme.delimiter` configuration | `map(string)` | `{}` | no |
| <a name="input_database_grants"></a> [database\_grants](#input\_database\_grants) | Grants on a database level | <pre>object({<br>    all_privileges    = optional(bool)<br>    with_grant_option = optional(bool, false)<br>    privileges        = optional(list(string), null)<br>  })</pre> | `{}` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | The name of the database to create the role in | `string` | n/a | yes |
| <a name="input_granted_database_roles"></a> [granted\_database\_roles](#input\_granted\_database\_roles) | Database Roles granted to this role | `list(string)` | `[]` | no |
| <a name="input_granted_to_database_roles"></a> [granted\_to\_database\_roles](#input\_granted\_to\_database\_roles) | Fully qualified Parent Database Role name (`DB_NAME.ROLE_NAME`), to create parent-child relationship | `list(string)` | `[]` | no |
| <a name="input_granted_to_roles"></a> [granted\_to\_roles](#input\_granted\_to\_roles) | List of Snowflake Account Roles to grant this role to | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the resource | `string` | n/a | yes |
| <a name="input_name_scheme"></a> [name\_scheme](#input\_name\_scheme) | Naming scheme configuration for the resource. This configuration is used to generate names using context provider:<br>    - `properties` - list of properties to use when creating the name - is superseded by `var.context_templates`<br>    - `delimiter` - delimited used to create the name from `properties` - is superseded by `var.context_templates`<br>    - `context_template_name` - name of the context template used to create the name<br>    - `replace_chars_regex` - regex to use for replacing characters in property-values created by the provider - any characters that match the regex will be removed from the name<br>    - `extra_values` - map of extra label-value pairs, used to create a name | <pre>object({<br>    properties            = optional(list(string), ["environment", "name"])<br>    delimiter             = optional(string, "_")<br>    context_template_name = optional(string, "snowflake-user")<br>    replace_chars_regex   = optional(string, "[^a-zA-Z0-9_]")<br>    extra_values          = optional(map(string))<br>  })</pre> | `{}` | no |
| <a name="input_parent_database_role"></a> [parent\_database\_role](#input\_parent\_database\_role) | DEPRECATED variable - please use `granted_to_database_roles` instead | `string` | `null` | no |
| <a name="input_schema_grants"></a> [schema\_grants](#input\_schema\_grants) | Grants on a schema level | <pre>list(object({<br>    all_privileges             = optional(bool)<br>    with_grant_option          = optional(bool, false)<br>    privileges                 = optional(list(string), null)<br>    all_schemas_in_database    = optional(bool, false)<br>    future_schemas_in_database = optional(bool, false)<br>    schema_name                = optional(string, null)<br>  }))</pre> | `[]` | no |
| <a name="input_schema_objects_grants"></a> [schema\_objects\_grants](#input\_schema\_objects\_grants) | Grants on a schema object level<br><br>  Example usage:<br><br>  schema\_objects\_grants = {<br>    "TABLE" = [<br>      {<br>        privileges  = ["SELECT"]<br>        object\_name = snowflake\_table.table\_1.name<br>        schema\_name = snowflake\_schema.this.name<br>      },<br>      {<br>        all\_privileges = true<br>        object\_name    = snowflake\_table.table\_2.name<br>        schema\_name    = snowflake\_schema.this.name<br>      }<br>    ]<br>    "ALERT" = [<br>      {<br>        all\_privileges = true<br>        on\_future      = true<br>        on\_all         = true<br>      }<br>    ]<br>  }<br><br>  Note: If you don't provide a schema\_name, the grants will be created for all objects of that type in the database.<br>        You can find a list of all object types [here](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_privileges_to_database_role#object_type) | <pre>map(list(object({<br>    all_privileges    = optional(bool)<br>    with_grant_option = optional(bool)<br>    privileges        = optional(list(string))<br>    object_name       = optional(string)<br>    on_all            = optional(bool, false)<br>    schema_name       = optional(string)<br>    on_future         = optional(bool, false)<br>  })))</pre> | `{}` | no |

## Modules

No modules.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fully_qualified_name"></a> [fully\_qualified\_name](#output\_fully\_qualified\_name) | Name of the database role in fully qualified format ("DB\_NAME"."ROLE\_NAME") |
| <a name="output_name"></a> [name](#output\_name) | Name of the database role |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_context"></a> [context](#provider\_context) | >=0.4.0 |
| <a name="provider_snowflake"></a> [snowflake](#provider\_snowflake) | >= 0.90 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_context"></a> [context](#requirement\_context) | >=0.4.0 |
| <a name="requirement_snowflake"></a> [snowflake](#requirement\_snowflake) | >= 0.90 |

## Resources

| Name | Type |
|------|------|
| [snowflake_database_role.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/database_role) | resource |
| [snowflake_grant_database_role.granted_database_roles](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_database_role) | resource |
| [snowflake_grant_database_role.granted_to_database_roles](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_database_role) | resource |
| [snowflake_grant_database_role.granted_to_role](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_database_role) | resource |
| [snowflake_grant_database_role.parent_database_role](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_database_role) | resource |
| [snowflake_grant_privileges_to_database_role.database_grants](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_privileges_to_database_role) | resource |
| [snowflake_grant_privileges_to_database_role.schema_grants](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_privileges_to_database_role) | resource |
| [snowflake_grant_privileges_to_database_role.schema_objects_grants](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_privileges_to_database_role) | resource |
| [context_label.this](https://registry.terraform.io/providers/cloudposse/context/latest/docs/data-sources/label) | data source |
<!-- END_TF_DOCS -->

## CONTRIBUTING

Contributions are very welcomed!

Start by reviewing [contribution guide](CONTRIBUTING.md) and our [code of conduct](CODE_OF_CONDUCT.md). After that, start coding and ship your changes by creating a new PR.

## LICENSE

Apache 2 Licensed. See [LICENSE](LICENSE) for full details.

## AUTHORS

<!--- Replace repository name -->
<a href="https://github.com/getindata/terraform-snowflake-database-role/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=getindata/terraform-module-template" />
</a>

Made with [contrib.rocks](https://contrib.rocks).
