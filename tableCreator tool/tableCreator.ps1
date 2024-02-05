
param (
    [string]$tableName = $(Read-Host -Prompt "Enter TableName to get Schema from: "),
    [string]$newTableName = $(Read-Host -Prompt "Enter new TableName to be created with the same Schema (remember _CL -suffix): ")
)

az config set extension.use_dynamic_install=yes_without_prompt

# Define your Sentinel workspace details
$workspaceId = "YOUR_WORKSPACE_ID"
$resourceId = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RESOURCE_GROUP/providers/Microsoft.OperationalInsights/workspaces/YOUR_WORKSPACE_NAME"

# Set query how to get schema of a table
$query = "$tableName | getschema | project ColumnName, ColumnType"

# Query the workspace
Write-Host "[Querying $tableName table schema...]"
$queryResult = az monitor log-analytics query -w $workspaceId --analytics-query $query -o json | ConvertFrom-Json

$exitCode = $LASTEXITCODE

# Check the exit code for success or failure
if ($exitCode -eq 0) {
    Write-Host "[Table schema successfully captured]"
}
else {
    Write-Host "ERROR executing the query. Exit code: $exitCode"
    exit
}

# Exclude specific columns by name
$columns = $queryResult | Where-Object { $_.ColumnName -notin @("TenantId", "Type", "Id") } | ForEach-Object {
    @{
        "name" = $_.ColumnName
        "type" = $_.ColumnType
    }
}

# Output the columns as raw JSON for debugging purposes
#Write-Host "Columns:"
#$columns | ConvertTo-Json

# Construct the tableParams
$tableParams = @{
    "properties" = @{
        "schema" = @{
            "name" = $newTableName
            "columns" = $columns
        }
    }
} | ConvertTo-Json -Depth 10

Write-Host "[Initiating new table $newTableName creation with the same schema as in $tableName]"

# Create the new Sentinel table
Invoke-AzRestMethod -Path "$resourceId/tables/${newTableName}?api-version=2021-12-01-preview" -Method PUT -Payload $tableParams

