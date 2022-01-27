variable "repo_url" {
  description = "Databricks Repo URL"
  default     = "https://github.com/databricks-academy/data-engineering-with-databricks.git"
}

variable "notebook_path" {
  description = "Notebook Relative Path"
  default     = "Data-Engineering-With-Databricks/01 - Databricks Lakehouse Platform/DE 1.3.1 - Managing Delta Tables"
}

variable "course_name" {
  description = "DBFS/Database Namespace Separator"
  default     = "dewd"
}

variable "metastore" {
  description = "Target metastore"
  default     = "hive_metastore"
}
