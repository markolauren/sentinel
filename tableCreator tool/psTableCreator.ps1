<#
.SYNOPSIS
    This script creates a new table in Azure Sentinel with the same schema as an existing table.

.DESCRIPTION
    The script connects to an Azure account, queries the schema of an existing table in Azure Sentinel, and creates a new table with the same schema. It excludes specific columns by name ("TenantId", "Type", "Id").

.PARAMETER tenantId
    The Tenant ID of the Azure account.

.PARAMETER subscriptionId
    The Subscription ID of the Azure account.

.PARAMETER resourceGroup
    The Resource Group where the Azure Sentinel workspace is located.

.PARAMETER workspaceName
    The name of the Azure Sentinel workspace.

.PARAMETER workspaceId
    The ID of the Azure Sentinel workspace.

.PARAMETER tableName
    The name of the existing table from which the schema will be copied.

.PARAMETER newTableName
    The name of the new table to be created.

.EXAMPLE
    ./psTableCreator.ps1 -tenantId "your-tenant-id" -subscriptionId "your-subscription-id" -resourceGroup "your-resource-group" -workspaceName "your-workspace-name" -workspaceId "your-workspace-id" -tableName "your-table-name" -newTableName "your-new-table-name"

#>


param (

    [Parameter(Mandatory = $true)]
    [string]$tenantId,

    [Parameter(Mandatory = $true)]
    [string]$subscriptionId,

    [Parameter(Mandatory = $true)]
    [string]$resourceGroup,

    [Parameter(Mandatory = $true)]
    [string]$workspaceName,

    [Parameter(Mandatory = $true)]
    [string]$workspaceId,

    [Parameter(Mandatory = $true)]
    [string]$tableName,

    [Parameter(Mandatory = $true)]
    [string]$newTableName
    
)

# Connect Azure Account
Connect-AzAccount -tenantId $TenantId

# Define your Sentinel workspace details
$resourceId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.OperationalInsights/workspaces/$workspaceName"

# Set query how to get schema of a table
$query = "$tableName | getschema | project ColumnName, ColumnType"

# Query the workspace
Write-Host "[Querying $tableName table schema...]"

$queryResult = Invoke-AzOperationalInsightsQuery -WorkspaceId $workspaceId -Query $query | Select-Object Results

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
$columns = $queryResult.Results | Where-Object { $_.ColumnName -notin @("TenantId", "Type", "Id") } | ForEach-Object {
    @{
        "name" = $_.ColumnName
        "type" = $_.ColumnType
    }
}

# Construct the tableParams
$newTableName = $newTableName -replace '[^a-zA-Z0-9]', ''
$newTableName = $newTableName + "_CL"
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
Invoke-AzRestMethod -Path "${resourceId}/tables/${newTableName}?api-version=2021-12-01-preview" -Method PUT -Payload $tableParams
