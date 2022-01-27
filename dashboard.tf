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
      "clusteringMode": "e",
      "steps": 5,
      "valueFormat": "‘($ 0.00 a)’",
      "noValuePlaceholder": "N/A",
      "colors": {
          "min": "#799CFF",
          "max": "#002FB4",
          "background": "#ffffff",
          "borders": "#ffffff",
          "noValue": "#dddddd"
      },
      "legend": {
          "visible": true,
          "position": "bottom-left",
          "alignText": "right",
          "traceorder": "normal"
      },
      "tooltip": {
          "enabled": true,
          "template": "<b>{{ @@name }}</b>: {{ @@value }}"
      },
      "popup": {
          "enabled": true,
          "template": "Country: <b>{{ @@name_long }} ({{ @@iso_a2 }})</b>\n<br>\nValue: <b>{{ @@value }}</b>"
      },
      "version": 2,
      "globalSeriesType": "column",
      "sortX": true,
      "sortY": true,
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
              "column": "state"
          },
          "y": [
              {
                  "column": "revenue"
              }
          ]
      },
      "showPlotlyControls": true
    }
  )
}
