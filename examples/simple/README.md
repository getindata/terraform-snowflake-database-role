# Simple Example

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

## Usage
```
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

<!-- BEGIN_TF_DOCS -->




## Inputs

No inputs.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_snowflake_database_role"></a> [snowflake\_database\_role](#module\_snowflake\_database\_role) | ../../ | n/a |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_snowflake_database_role"></a> [snowflake\_database\_role](#output\_snowflake\_database\_role) | Snowflake database role outputs |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_snowflake"></a> [snowflake](#provider\_snowflake) | 0.87.2 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_snowflake"></a> [snowflake](#requirement\_snowflake) | 0.87.2 |

## Resources

| Name | Type |
|------|------|
| [snowflake_database.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.87.2/docs/resources/database) | resource |
| [snowflake_schema.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.87.2/docs/resources/schema) | resource |
<!-- END_TF_DOCS -->
