resource "databricks_repo" "dewd" {
  url = "https://github.com/databricks-academy/data-engineering-with-databricks.git"
  path = "${data.databricks_current_user.me.home}/Terraform/DEWD_repo"
}
