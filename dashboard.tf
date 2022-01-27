resource "databricks_sql_endpoint" "endpoint" {
  name             = "Endpoint of ${data.databricks_current_user.me.alphanumeric}"
  cluster_size     = "Small"
  max_num_clusters = 1
}

resource "databricks_sql_query" "revenue_by_state" {
  data_source_id = databricks_sql_endpoint.endpoint.data_source_id
  name           = "Revenue by State"
  query          = "SELECT state,SUM(order.qty*order.price) AS revenue FROM (SELECT customer_name,order_datetime,EXPLODE(ordered_products) AS order,state FROM ${var.metastore}.${databricks_pipeline_pipeline.target}.sales_orders_cleaned) GROUP BY state ORDER BY state"
  run_as_role    = "viewer"
}
