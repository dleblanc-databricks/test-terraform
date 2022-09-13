resource "databricks_schema" "myschema" {
    catalog_name = "main"
    name         = "myschema_tfc"
    comment      = "This schema is managed by Terraform Cloud"
}
