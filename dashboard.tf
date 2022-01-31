resource "databricks_sql_endpoint" "endpoint" {
  name             = "${data.databricks_current_user.me.alphanumeric} (Terraform)"
  cluster_size     = "Small"
  max_num_clusters = 1
}

resource "databricks_sql_query" "revenue_by_state" {
  data_source_id = databricks_sql_endpoint.endpoint.data_source_id
  name           = "Revenue by State"
  query          = "SELECT state,SUM(order.qty*order.price) AS revenue FROM (SELECT customer_name,order_datetime,EXPLODE(ordered_products) AS order,state FROM ${var.metastore}.${databricks_pipeline.pipeline.target}.sales_orders_cleaned) GROUP BY state ORDER BY state"
  run_as_role    = "viewer"
  
  tags = [
    "Terraform"
  ]
}

resource "databricks_sql_query" "sales_over_time" {
  data_source_id = databricks_sql_endpoint.endpoint.data_source_id
  name           = "Sales Over Time"
  query          = "SELECT DATE_FORMAT(order_datetime, 'y-MM-dd') AS day, SUM(order.qty*order.price) AS revenue FROM (SELECT customer_name,order_datetime,EXPLODE(ordered_products) AS order,state FROM ${var.metastore}.${databricks_pipeline.pipeline.target}.sales_orders_cleaned WHERE order_datetime IS NOT NULL) GROUP BY day ORDER BY day"
  run_as_role    = "viewer"

  tags = [
    "Terraform"
  ]
}

resource "databricks_sql_query" "top_ten_customers" {
  data_source_id = databricks_sql_endpoint.endpoint.data_source_id
  name           = "Customer Leaderboard"
  query          = "SELECT customer_name,SUM(order.qty*order.price) AS revenue FROM (SELECT customer_name,order_datetime,EXPLODE(ordered_products) AS order,state FROM ${var.metastore}.${databricks_pipeline.pipeline.target}.sales_orders_cleaned) GROUP BY customer_name ORDER BY revenue DESC LIMIT 10"
  run_as_role    = "viewer"

  tags = [
    "Terraform"
  ]
}

resource "databricks_sql_query" "count_customers" {
  data_source_id = databricks_sql_endpoint.endpoint.data_source_id
  name           = "Customer Count"
  query          = "SELECT COUNT(DISTINCT(customer_id)) FROM ${var.metastore}.${databricks_pipeline.pipeline.target}.sales_orders_cleaned"
  run_as_role    = "viewer"

  tags = [
    "Terraform"
  ]
}

resource "databricks_sql_query" "count_items_sold" {
  data_source_id = databricks_sql_endpoint.endpoint.data_source_id
  name           = "Items Sold"
  query          = "SELECT SUM(order.qty) FROM (SELECT customer_name,order_datetime,EXPLODE(ordered_products) AS order,state FROM ${var.metastore}.${databricks_pipeline.pipeline.target}.sales_orders_cleaned)"
  run_as_role    = "viewer"

  tags = [
    "Terraform"
  ]
}

resource "databricks_sql_visualization" "revenue_by_state" {
  query_id    = databricks_sql_query.revenue_by_state.id
  type        = "choropleth"
  name        = "Revenue by State"
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
  name        = "Sales Over Time"
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

resource "databricks_sql_visualization" "top_ten_customers" {
  query_id    = databricks_sql_query.top_ten_customers.id
  type        = "table"
  name        = "Customer Leaderboard"
  options = jsonencode(
    {
      "itemsPerPage": 10,
      "condensed": false,
      "columns": [
          {
              "booleanValues": [
                  "false",
                  "true"
              ],
              "imageUrlTemplate": "{{ @ }}",
              "imageTitleTemplate": "{{ @ }}",
              "imageWidth": "",
              "imageHeight": "",
              "linkUrlTemplate": "{{ @ }}",
              "linkTextTemplate": "{{ @ }}",
              "linkTitleTemplate": "{{ @ }}",
              "linkOpenInNewTab": true,
              "name": "customer_name",
              "type": "string",
              "displayAs": "string",
              "visible": true,
              "order": 100000,
              "title": "Customer",
              "allowSearch": false,
              "alignContent": "left",
              "allowHTML": false,
              "highlightLinks": false,
              "useMonospaceFont": false,
              "preserveWhitespace": false
          },
          {
              "numberFormat": "‘($ 0.00 a)’",
              "booleanValues": [
                  "false",
                  "true"
              ],
              "imageUrlTemplate": "{{ @ }}",
              "imageTitleTemplate": "{{ @ }}",
              "imageWidth": "",
              "imageHeight": "",
              "linkUrlTemplate": "{{ @ }}",
              "linkTextTemplate": "{{ @ }}",
              "linkTitleTemplate": "{{ @ }}",
              "linkOpenInNewTab": true,
              "name": "revenue",
              "type": "integer",
              "displayAs": "number",
              "visible": true,
              "order": 100001,
              "title": "Purchased",
              "allowSearch": false,
              "alignContent": "right",
              "allowHTML": false,
              "highlightLinks": false,
              "useMonospaceFont": false,
              "preserveWhitespace": false
          }
      ],
      "version": 2,
      "showPlotlyControls": true
    }
  )
}

resource "databricks_sql_visualization" "count_customers" {
  query_id    = databricks_sql_query.count_customers.id
  type        = "counter"
  name        = "Customer Count"
  options = jsonencode(
    {
      "counterLabel": "Customers",
      "counterColName": "count(DISTINCT customer_id)",
      "rowNumber": 1,
      "targetRowNumber": 1,
      "stringDecimal": 0,
      "stringDecChar": ".",
      "stringThouSep": ",",
      "tooltipFormat": "0,0.000",
      "showPlotlyControls": true
    }
  )
}

resource "databricks_sql_visualization" "count_items_sold" {
  query_id    = databricks_sql_query.count_items_sold.id
  type        = "counter"
  name        = "Customer Count"
  options = jsonencode(
    {
      "counterLabel": "Items Sold",
      "counterColName": "sum(order.qty)",
      "rowNumber": 1,
      "targetRowNumber": 1,
      "stringDecimal": 0,
      "stringDecChar": ".",
      "stringThouSep": ",",
      "tooltipFormat": "0,0.000",
      "showPlotlyControls": true
    }
  )
}

resource "databricks_sql_dashboard" "dashboard" {
  name = "Sales Dashboard"

  tags = [
    "Terraform"
  ]
}

resource "databricks_sql_widget" "revenue_by_state" {
  dashboard_id = databricks_sql_dashboard.dashboard.id
  visualization_id = databricks_sql_visualization.revenue_by_state.id

  position {
    size_x = 3
    size_y = 9
    pos_x = 0
    pos_y = 5
  }

  title = "Total Sales by State"
}

resource "databricks_sql_widget" "sales_over_time" {
  dashboard_id = databricks_sql_dashboard.dashboard.id
  visualization_id = databricks_sql_visualization.sales_over_time.id

  position {
    size_x = 3
    size_y = 6
    pos_x = 3
    pos_y = 8
  }
  
  title = "Daily Sales"
}

resource "databricks_sql_widget" "top_ten_customers" {
  dashboard_id = databricks_sql_dashboard.dashboard.id
  visualization_id = databricks_sql_visualization.top_ten_customers.id

  position {
    size_x = 3
    size_y = 8
    pos_x = 3
    pos_y = 0
  }

  title = "Top Ten Customers"
}

resource "databricks_sql_widget" "count_customers" {
  dashboard_id = databricks_sql_dashboard.dashboard.id
  visualization_id = databricks_sql_visualization.count_customers.id

  position {
    size_x = 1
    size_y = 5
    pos_x = 1
    pos_y = 0
  }

  title = ""
}

resource "databricks_sql_widget" "count_items_sold" {
  dashboard_id = databricks_sql_dashboard.dashboard.id
  visualization_id = databricks_sql_visualization.count_items_sold.id

  position {
    size_x = 1
    size_y = 5
    pos_x = 2
    pos_y = 0
  }
  
  title = "no title"
}

resource "databricks_sql_widget" "title" {
  dashboard_id = databricks_sql_dashboard.dashboard.id
  text = "# Sales Overview"

  position {
    size_x = 1
    size_y = 5
    pos_x = 0
    pos_y = 0
  }
}
