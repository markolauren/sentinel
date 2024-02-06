tableCreator.ps1
- a tool to capture Sentinel table SCHEMA and create new table with same schema!

Usage:

1) Modify the script with your own Sentinel 
$workspaceId = "YOUR_WORKSPACE_ID"
$resourceId = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RESOURCE_GROUP/providers/Microsoft.OperationalInsights/workspaces/YOUR_WORKSPACE_NAME"

2) Run the tool IN AZURE CLOUD SHELL !!

./tableCreator.ps1 - and you will be asked TableName which schema we want to use, and NEW TableName which will be created using the same schema

OR

./tableCreator.ps1 -tableName existing_table_where_we_get_the_schema -newTableName new_table_we_create_based_on_same_schema
