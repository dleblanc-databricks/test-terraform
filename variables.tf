variable "repo_url" {
  description = "Databricks Repo URL"
  default     = "https://github.com/databricks-academy/data-engineering-with-databricks.git"
}

variable "notebook_path" {
  description = "Notebook Relative Path"
  default     = "Data-Engineering-With-Databricks/01 - Databricks Lakehouse Platform/DE 1.3.1 - Managing Delta Tables"
}

variable "dlt_notebook_path" {
  description = "Pipeline Notebook Relative Path"
  default     = "Data-Engineering-With-Databricks/03 - Incremental Data and Delta Live Tables/DE 3.3.2 - SQL for Delta Live Tables"
}

variable "course_name" {
  description = "DBFS/Database Namespace Separator"
  default     = "dewd"
}
