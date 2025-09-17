# tableCreator.ps1 (v2.3) - UPDATED 17.9.2025
### 💡 A tool to capture the schema of existing Sentinel table, and create new table with same schema!
https://github.com/markolauren/sentinel/blob/main/tableCreator%20tool/tableCreator.ps1

### What's new in v2.3
🆕 Supprot for -FullResourceId option to define your Sentinel resourceID directly in a command line, no script editing necessary anymore. Kudos to TristankMS <br/> 

### What's new in v2.2
🆕 Data lake tier support <br/> 

### What's new in v2.1
🆕 Support for -ConvertToString flag: Use with Aux logs to convert dynamic columns to string <br/> 

### What's new in v2.0
🆕 Support for defining interactive retention (for Analytics tier) <br/>
🆕 Support for defining total retention <br/>
🆕 Improved error handling <br/>
🆕 Command line & visual improvements <br/>

### Usage:

1) **Define your Sentinel resourceID**  <br/>
Use -FullResourceId switch to define your Sentinel resourceID <br/>
_tableCreator.ps1 -FullResourceID /subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RESOURCE_GROUP/providers/Microsoft.OperationalInsights/workspaces/YOUR_WORKSPACE_NAME_ <br/>
**OR** <br/>
Modify the script with (line 36) your own Sentinel resourceID <br/>
_$resourceId = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RESOURCE_GROUP/providers/Microsoft.OperationalInsights/workspaces/YOUR_WORKSPACE_NAME"_ <br/>
 (To obtain this information, open "Log Analytics workspaces" in Azure - choose your Workspace - choose Properties - Resource ID)<br/><br/>

2) **Run the tool IN AZURE CLOUD SHELL !!**

- **./tableCreator.ps1** - and you will be asked TableName which schema we want to use, and new TableName which will be created using the same schema, table type, retention and total retention.

![screenshot](https://github.com/user-attachments/assets/951c0756-0bf8-474f-9712-9308c066d879)

&nbsp;&nbsp;&nbsp;OR

- **Command line usage**:<br/>
.\tableCreator.ps1 **-tableName** tableName **-newTableName** newTableName **-type** <analytics|basic|aux|auxiliary> **-retention** retentionInDays **-totalRetention** TotalRetentionInDays (**-ConvertToString**) (**-FullResourceId** sentinelResourceId)<br/>

Examples: <br/>
.\tableCreator.ps1 -tableName MyTable -newTableName MyNewTable_CL -type analytics -retention 180 -totalRetention 365 <br/>
.\tableCreator.ps1 -tableName CommonSecurityLog -newTableName AuxCommonSecLog_CL -type aux -retention 30 -totalRetention 365 <br/>
.\tableCreator.ps1 -tableName AADNonInteractiveUserSignInLogs -newTableName AADNonInteractiveSignin_CL -type aux -retention 30 -totalRetention 365 -ConvertToString <br/>


#### NOTICE: 
This tool uses kql "getschema", and for some reason it reports all the columns with type "guid" as "string". <br/>
If the table you're creating a copy has guid type column(s) it causes a mismatch with column types when creating DCR. Workaround is to modify DCR with transformKql:<br/>
_"transformKql": "source | extend SomeGuid = tostring(SomeGuid), AnotherGuid = tostring(AnotherGuid)"_ <br/>
Another workaround is to debug the script and interpret those columns on the fly. This is already done for SecurityEvent table. 
