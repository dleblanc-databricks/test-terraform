resource "databricks_sql_endpoint" "endpoint" {
  name             = "Endpoint of ${data.databricks_current_user.me.alphanumeric}"
  cluster_size     = "Small"
  max_num_clusters = 1
}

resource "databricks_sql_query" "revenue_by_state" {
  data_source_id = databricks_sql_endpoint.endpoint.data_source_id
  name           = "Revenue by State (Terraform)"
  query          = "SELECT state,SUM(order.qty*order.price) AS revenue FROM (SELECT customer_name,order_datetime,EXPLODE(ordered_products) AS order,state FROM ${var.metastore}.${databricks_pipeline.pipeline.target}.sales_orders_cleaned) GROUP BY state ORDER BY state"
  run_as_role    = "viewer"
}

resource "databricks_sql_query" "sales_over_time" {
  data_source_id = databricks_sql_endpoint.endpoint.data_source_id
  name           = "Sales Over Time (Terraform)"
  query          = "SELECT DATE_FORMAT(order_datetime, 'y-MM-dd') AS day, SUM(order.qty*order.price) AS revenue FROM (SELECT customer_name,order_datetime,EXPLODE(ordered_products) AS order,state FROM hive_metastore.dbacademy_david_leblanc_dewd.sales_orders_cleaned WHERE order_datetime IS NOT NULL) GROUP BY day ORDER BY day"
  run_as_role    = "viewer"
}

resource "databricks_sql_visualization" "revenue_by_state" {
  query_id    = databricks_sql_query.revenue_by_state.id
  type        = "choropleth"
  name        = "Revenue by State (Terraform)"

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

resource "databricks_sql_visualization" "sales_over_time" {
  query_id    = databricks_sql_query.sales_over_time.id
  type        = "chart"
  name        = "Sales Over Time (Terraform)"
  options = jsonencode(
    {
      "version": 2,
      "globalSeriesType": "line",
      "xAxis": {
          "type": "-",
          "labels": {
              "enabled": false
          },
          "title": {
              "text": "Time"
          }
      },
      "yAxis": [
          {
              "type": "-",
              "title": {
                  "text": "Sales"
              },
              "rangeMin": 0,
              "rangeMax": 4000000
          },
          {
              "type": "-",
              "opposite": true
          }
      ],
      "alignYAxesAtZero": false,
      "error_y": {
          "type": "data",
          "visible": true
      },
      "series": {
          "stacking": null,
          "error_y": {
              "type": "data",
              "visible": true
          }
      },
      "seriesOptions": {
        "revenue": {
            "yAxis": 0
        }
      },
      "valuesOptions": {},
      "direction": {
          "type": "counterclockwise"
      },
      "sizemode": "diameter",
      "coefficient": 1,
      "numberFormat": "0,0[.]00000",
      "percentFormat": "0[.]00%",
      "textFormat": "",
      "missingValuesAsZero": true,
      "useAggregationsUi": false,
      "swappedAxes": false,
      "dateTimeFormat": "YYYY-MM-DD HH:mm",
      "showDataLabels": false,
      "columnConfigurationMap": {
          "x": {
              "column": "day"
          },
          "y": [
              {
                  "column": "revenue"
              }
          ]
      },
      "showPlotlyControls": true,
      "hideXAxis": false
    }
  )
}
