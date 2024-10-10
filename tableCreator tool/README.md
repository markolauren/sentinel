# tableCreator.ps1 (v2)
💡 Tool to capture the schema of existing Sentinel table, and create new table with same schema!

### What's new
🆕 Support for choosing table plan/type: Analytics, Basic, Aux/Auxiliary <br/>
🆕 Support for defining interactive retention (for Analytics tier) <br/>
🆕 Support for defining total retention <br/>
🆕 Improved error handling <br/>
🆕 Command line & visual improvements <br/>
💡 Auxiliary plan is in preview and has some limitations. Script will try to cope with those (eg. drops columns with "dynamic" type). Also user always needs to set total retention as 365 (at least for now). <br/>

### Usage:

1) **Modify the script with your own Sentinel**

- $workspaceId = "YOUR_WORKSPACE_ID"
- $resourceId = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RESOURCE_GROUP/providers/Microsoft.OperationalInsights/workspaces/YOUR_WORKSPACE_NAME"

2) **Run the tool IN AZURE CLOUD SHELL !!**

- ./tableCreator.ps1 - and you will be asked TableName which schema we want to use, and new TableName which will be created using the same schema, table type, retention and total retention.

![screenshot](https://github.com/user-attachments/assets/951c0756-0bf8-474f-9712-9308c066d879)

&nbsp;&nbsp;&nbsp;OR

- Command line usage: .\tableCreator.ps1 -tableName <TableName> -newTableName <NewTableName> -type <analytics|basic|aux|auxiliary> -retention <RetentionInDays> -totalRetention <TotalRetentionInDays><br/>
<br/>
&nbsp;&nbsp;Example: .\tableCreator.ps1 -tableName MyTable -newTableName MyNewTable_CL -type analytics -retention 180 -totalRetention 365
