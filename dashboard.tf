resource "databricks_sql_endpoint" "endpoint" {
  name             = "Endpoint of ${data.databricks_current_user.me.alphanumeric}"
  cluster_size     = "Small"
  max_num_clusters = 1
}

resource "databricks_sql_query" "revenue_by_state" {
  data_source_id = databricks_sql_endpoint.endpoint.data_source_id
  name           = "Revenue by State (Terraform2)"
  query          = "SELECT state,SUM(order.qty*order.price) AS revenue FROM (SELECT customer_name,order_datetime,EXPLODE(ordered_products) AS order,state FROM ${var.metastore}.${databricks_pipeline.pipeline.target}.sales_orders_cleaned) GROUP BY state ORDER BY state"
  run_as_role    = "viewer"
}

resource "databricks_sql_visualization" "revenue_by_state" {
  query_id    = databricks_sql_query.revenue_by_state.id
  type        = "CHOROPLETH"
  name        = "Revenue by State (Terraform)"
  description = "Some Description"

  // The options encoded in this field are passed verbatim to the SQLA API.
  options = jsonencode(
    {
      "mapType": "usa",
      "keyColumn": "state",
      "targetField": "usps_abbrev",
      "valueColumn": "revenue",
      "valueFormat": "‘($ 0.00 a)’",
      "xAxis": {
          "type": "-",
          "labels": {
              "enabled": true
          },
          "title": {
              "text": "State"
          }
      },
      "yAxis": [
          {
              "type": "-",
              "title": {
                  "text": "Revenue"
              }
          },
          {
              "type": "-",
              "opposite": true
          }
      ],
      "columnConfigurationMap": {
          "x": {
              "column": "state"
          },
          "y": [
              {
                  "column": "revenue"
              }
          ]
      }
    }
  )
}
