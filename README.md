# test-terraform

## Overview
This repository provides a sample Terraform configuration that provisions the following assets into a Databricks workspace:
* Databricks Repo (pulls from the Associate DEWD public repo hosted at https://github.com/databricks-academy/data-engineering-with-databricks)
* DLT pipeline based on a Notebook contained within the Repo
* A DBSQL Dashboard with a number of visuals based on pipeline output

## Usage instructions

Before proceeding, you will need your Databricks access URL and a PAT for that workspace.

In Terraform Cloud, perform the following:
* Create a variable set containing two environment variables, available to all workspaces. Mark both variables as sensitive.
   1. **DATABRICKS_HOST**: set value to your access URL
   2. **DATABRICKS_TOKEN**: set value to generated PAT
* Create a new **Version control workflow** workspace
* Choose VCS and repository to specify this repository
* In the newly created workspace, choose **Actions &lt; Start new plan**.
* Select **Confirm & Apply**.

In Databricks:
* Locate and run the provisioned DLT in the **Jobs** page (note, this will take some time as a cluster must be provisioned as part of this process)
* Go to Databricks SQL, then click on the proisioned Dashboard 

