resource "databricks_pipeline" "pipeline" {
  name    = "Pipeline Name"
  storage = "${data.databricks_current_user.me.home}/dbacademy/${var.course_name}"
  target = "dbacademy_${data.databricks_current_user.me.alphanumeric}_${var.course_name}"

  library {
    notebook {
      path = "${databricks_repo.repo.path}/${var.dlt_notebook_path}"
    }
  }

  filters {
    include = ["com.databricks.include"]
    exclude = ["com.databricks.exclude"]
  }

  continuous = false
}
