# Complete Example

```terraform
resource "snowflake_database" "this" {
  name = "TEST_DB"
}

resource "snowflake_schema" "this" {
  database = snowflake_database.this.name
  name     = "BRONZE"
}

resource "snowflake_table" "table_1" {
  database = snowflake_schema.this.database
  schema   = snowflake_schema.this.name
  name     = "TEST_TABLE_1"

  column {
    name     = "identity"
    type     = "NUMBER(38,0)"
    nullable = true

    identity {
      start_num = 1
      step_num  = 3
    }
  }
}

resource "snowflake_table" "table_2" {
  database = snowflake_schema.this.database
  schema   = snowflake_schema.this.name
  name     = "TEST_TABLE_2"

  column {
    name     = "identity"
    type     = "NUMBER(38,0)"
    nullable = true

    identity {
      start_num = 1
      step_num  = 3
    }
  }
}

resource "snowflake_database_role" "db_role_1" {
  database = snowflake_database.this.name
  name     = "DB_ROLE_1"
}

resource "snowflake_database_role" "db_role_2" {
  database = snowflake_database.this.name
  name     = "DB_ROLE_2"
}

resource "snowflake_database_role" "db_role_3" {
  database = snowflake_database.this.name
  name     = "DB_ROLE_3"
}

module "snowflake_database_role" {
  source  = "../../"
  context = module.this.context

  database_name = snowflake_database.this.name
  name          = "TEST_DB_ROLE"


  parent_database_role = snowflake_database_role.db_role_1.name
  granted_database_roles = [
    snowflake_database_role.db_role_2.name,
    snowflake_database_role.db_role_3.name
  ]
  database_grants = [
    {
      privileges = ["USAGE", "CREATE SCHEMA"]
    },
  ]

  schema_grants = [
    {
      schema_name = snowflake_schema.this.name
      privileges  = ["USAGE"]
    },
    {
      future_schemas_in_database = true
      all_schemas_in_database    = true
      privileges                 = ["USAGE"]
    },
  ]

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
}
```

## Usage
```
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

<!-- BEGIN_TF_DOCS -->




## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_context_templates"></a> [context\_templates](#input\_context\_templates) | A map of context templates to use for generating user names | `map(string)` | n/a | yes |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_snowflake_database_role_1"></a> [snowflake\_database\_role\_1](#module\_snowflake\_database\_role\_1) | ../../ | n/a |
| <a name="module_snowflake_database_role_2"></a> [snowflake\_database\_role\_2](#module\_snowflake\_database\_role\_2) | ../../ | n/a |
| <a name="module_snowflake_database_role_3"></a> [snowflake\_database\_role\_3](#module\_snowflake\_database\_role\_3) | ../../ | n/a |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_snowflake_database_role_1"></a> [snowflake\_database\_role\_1](#output\_snowflake\_database\_role\_1) | Snowflake database role outputs |
| <a name="output_snowflake_database_role_2"></a> [snowflake\_database\_role\_2](#output\_snowflake\_database\_role\_2) | Snowflake database role outputs |
| <a name="output_snowflake_database_role_3"></a> [snowflake\_database\_role\_3](#output\_snowflake\_database\_role\_3) | Snowflake database role outputs |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_snowflake"></a> [snowflake](#provider\_snowflake) | >=0.97 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_context"></a> [context](#requirement\_context) | >=0.4.0 |
| <a name="requirement_snowflake"></a> [snowflake](#requirement\_snowflake) | >=0.97 |

## Resources

| Name | Type |
|------|------|
| [snowflake_account_role.role_1](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/account_role) | resource |
| [snowflake_account_role.role_2](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/account_role) | resource |
| [snowflake_database.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/database) | resource |
| [snowflake_database_role.db_role_1](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/database_role) | resource |
| [snowflake_database_role.db_role_2](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/database_role) | resource |
| [snowflake_database_role.db_role_3](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/database_role) | resource |
| [snowflake_grant_privileges_to_share.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/grant_privileges_to_share) | resource |
| [snowflake_schema.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/schema) | resource |
| [snowflake_share.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/share) | resource |
| [snowflake_table.table_1](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/table) | resource |
| [snowflake_table.table_2](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/table) | resource |
<!-- END_TF_DOCS -->
