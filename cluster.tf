resource "databricks_cluster" "mycluster" {
    num_workers = 1
    cluster_name = "mycluster_tfc"
    idempotency_token = "mycluster_tfc"
    spark_version = "11.1.x-scala2.12"
    node_type_id = "i3.xlarge"
    autotermination_minutes = 120
    data_security_mode = "USER_ISOLATION"
}
