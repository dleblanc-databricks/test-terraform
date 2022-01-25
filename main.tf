terraform {
  required_providers {
    databricks = {
      source = "databrickslabs/databricks"
    }
  }
}

provider "databricks" {}

data "databricks_current_user" "me" {}
data "databricks_spark_version" "latest" {}
data "databricks_node_type" "smallest" {
  local_disk = true
}

resource "databricks_job" "this" {
  name = "Terraform Repo Demo (${data.databricks_current_user.me.alphanumeric})"

  new_cluster {
    num_workers   = 1
    spark_version = data.databricks_spark_version.latest.id
    node_type_id  = data.databricks_node_type.smallest.id
  }

  notebook_task {
    notebook_path = "${databricks_repo.dewd.path}/Data-Engineering-With-Databricks/01 - Databricks Lakehouse/DE 1.3.1 - Managing Delta Tables.sql"
  }
}

output "notebook_url" {
  value = databricks_repo.dewd.url
}

output "job_url" {
  value = databricks_job.this.url
}
