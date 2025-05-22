##################################################################################################################
# Command line usage:
# .\tableCreator.ps1 -tableName <TableName> -newTableName <NewTableName> -type <analytics|basic|aux|auxiliary> -retention <RetentionInDays> -totalRetention <TotalRetentionInDays>
#
# For Auxiliary tables, use the -ConvertToString switch to convert dynamic columns to string.
#
# The script will prompt for any missing parameters.
#
# Examples:
# .\tableCreator.ps1 -tableName MyTable -newTableName MyNewTable_CL -type analytics -retention 180 -totalRetention 365 
# .\tableCreator.ps1 -ConvertToString
##################################################################################################################

# Define parameters for the script
param (
    [string]$tableName,
    [string]$newTableName,
    [string]$type,
    [int]$retention,
    [int]$totalRetention,
    [switch]$ConvertToString
)

##################################################################################################################
$resourceId = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RESOURCE_GROUP/providers/Microsoft.OperationalInsights/workspaces/YOUR_WORKSPACE_NAME"
##################################################################################################################

# Display the banner
Write-Host " +=======================+"
Write-Host " | tableCreator.ps1 v2.1 |"
Write-Host " +=======================+"
Write-Host ""

# Function to repeatedly prompt for input until a valid value is entered
function PromptForInput {
    param (
        [string]$promptMessage
    )

    $inputValue = ""
    while (-not $inputValue) {
        $inputValue = Read-Host -Prompt $promptMessage
        if (-not $inputValue) {
            Write-Host "This value is required. Please provide a valid input."
        }
    }

    return $inputValue
}

# Prompt for input if necessary
if (-not $tableName) {
    $tableName = PromptForInput "Enter TableName to get Schema from"
} 

if (-not $newTableName) {
    $newTableName = PromptForInput "Enter new TableName to be created with the same Schema (remember _CL -suffix)"
}

# Prompt for table type, defaulting to 'analytics' if not provided
if (-not $type) {
    $type = Read-Host -Prompt "Enter table type (analytics, basic or aux/auxiliary, or press Enter for default 'analytics')"
}

if ($type.ToLower() -eq "aux") { $type = "auxiliary" }

# Define an array of valid types
$validTypes = @("auxiliary", "basic", "analytics")

$type = $type.ToLower()

# If $type is not valid, default it to 'analytics'
if (-not $type -or -not ($validTypes -contains $type)) {
    $type = 'analytics'
    Write-Host "Invalid or no table type provided. Defaulting to 'analytics'."
}

# Prompt for retention values if not provided
if (-not $retention -and $type -eq "analytics") {
    $retention = Read-Host -Prompt "Enter interactive retention in days (30-730) or press Enter for workspace default"
}

if (-not $totalRetention) {
    $totalRetention = Read-Host -Prompt "Enter total retention in days (30-4383) or press Enter for table default"
}

# Suppress output for the az config command
#az config set extension.use_dynamic_install=yes_without_prompt *>$null

# Set query to get the schema of the specified table
$query = "$tableName | getschema | project ColumnName, ColumnType"

# Query the workspace to get the schema
Write-Host "[Querying $tableName table schema...]"

### OLD IMPLEMENTATION #############################################################################################
#$queryResult = az monitor log-analytics query -w $workspaceId --analytics-query $query -o json | ConvertFrom-Json
#
#$exitCode = $LASTEXITCODE
#
## Check the exit code for success or failure
#if ($exitCode -eq 0) {
#    Write-Host "[Table schema successfully captured]"
#} else {
#    Write-Host "ERROR executing the query. Exit code: $exitCode"
#    exit
#}
### OLD IMPLEMENTATION ENDS ########################################################################################

### NEW IMPLEMENTATION #############################################################################################
$body = @{
    query = $query
} | ConvertTo-Json -Depth 2

$response = Invoke-AzRestMethod -Path "$resourceId/query?api-version=2017-10-01" -Method POST  -Payload $body

# Convert Content from JSON string to PowerShell object
$data = $response.Content | ConvertFrom-Json

# Check if the response contains StatusCode
if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 202) {
    Write-Host "[Table schema successfully captured]"
}
else {
    # Output error details if the creation failed
    Write-Host "[Error] Failed to query the table '$TableName'. Status code: $($response.StatusCode)" -ForegroundColor Red
    
    exit
}

# do the mapping to queryResult
$columns = $data.tables[0].columns
$rows = $data.tables[0].rows

$queryResult = $rows | ForEach-Object {
    $object = @{}
    for ($i = 0; $i -lt $columns.Count; $i++) {
        $object[$columns[$i].name] = $_[$i]
    }
    [pscustomobject]$object
}

### NEW IMPLEMENTATION ENDS ########################################################################################

$StringList = @()

# Exclude specific columns by name and prepare the columns for tableParams
$columns = $queryResult | Where-Object {
    $_.ColumnName -notin @("TenantId", "Type", "Id", "MG")
} | ForEach-Object {

    ## AUX uses column type boolean istead of bool, which is weird.
    if ($type -eq "auxiliary" -and $_.ColumnType -eq "bool") { 
        $_.ColumnType = "boolean" 
    }

    # Check if the column type is dynamic and if ConvertToString is set
    if ($type -eq "auxiliary" -and $_.ColumnType -eq "dynamic") {
        if ($ConvertToString) { 

            $StringList += $_.ColumnName  # Add to array for later processing

            $_.ColumnName = $_.ColumnName + "_str"
            $_.ColumnType = "string"

            #Write-Host "[DEBUG - CONVERTED $($_.ColumnName) - $($_.ColumnType)"        
        } 
    }

    # Check if the table name is "SecurityEvent" and specific columns which are type guid. Getschema fails to report these properly, so it needs some manual intervention.
    if ($_.ColumnName -in @("InterfaceUuid", "LogonGuid", "SourceComputerId", "SubcategoryGuid", "TargetLogonGuid") -and $tableName -eq "SecurityEvent") {
        $_.ColumnType = "guid"
    }
    # Check if the table name is "SigninLogs" and specific columns which are type guid. Getschema fails to report these properly, so it needs some manual intervention.
    if ($_.ColumnName -in @("OriginalRequestId") -and $tableName -eq "SigninLogs") {
        $_.ColumnType = "guid"
    }

     ## AUX do not support dynamic tables
    if ($type -eq "auxiliary" -and $_.ColumnType -eq "dynamic" -and !($ConvertToString)) {

        # Log the skipping message
        Write-Host "[SKIPPING $($_.ColumnName) due to Dynamic type which is not supported by Auxiliary table, use -ConvertToString to convert it to String]" 

    } else {
        # Include the column in the result
        @{
            "name" = $_.ColumnName
            "type" = $_.ColumnType
        }
        #Write-Host "[DEBUG - INCL $($_.ColumnName) - $($_.ColumnType)"

    }

}

# Construct the base tableParams for the new table
$tableParams = @{
    "properties" = @{
        "schema" = @{
            "name"    = $newTableName
            "columns" = $columns
        }
    }
}

# Normalize the type input and add details if set
switch ($type.ToLower()) {
    "auxiliary" {
        $tableParams.properties.plan = "Auxiliary"
        Write-Host "[Plan set to Auxiliary]"
        Write-Host "[Interactive retention is always 30 days]"
    }
    "analytics" {
        $tableParams.properties.plan = "Analytics"
        Write-Host "[Plan set to Analytics]"
        if ($retention -ge 30 -and $retention -le 730) {
            $tableParams.properties.retentionInDays = $retention
            Write-Host "[Interactive retention set to $retention days]"
        }
    }
    "basic" {
        $tableParams.properties.plan = "Basic"
        Write-Host "[Plan set to Basic]"
        Write-Host "[Interactive retention is always 30 days]"
    }
    default {
        Write-Host "Invalid type provided. Using default 'analytics'."
        $tableParams.properties.plan = "Analytics"
        Write-Host "[Plan set to Analytics]"
        if ($retention -ge 30 -and $retention -le 730) {
            $tableParams.properties.retentionInDays = $retention
            Write-Host "[Interactive Retention set to $retention days]"
        }
    }
}

# Set totalRetentionInDays based on the input condition
if ($totalRetention -ge 30 -and $totalRetention -le 4383) { 
    $tableParams.properties.totalRetentionInDays = $totalRetention 
    Write-Host "[Total retention set to $totalRetention days]"
} 

# Convert tableParams to JSON for the API call
$tableParamsJson = $tableParams | ConvertTo-Json -Depth 10
#Write-Host "$tableParamsJson"

Write-Host "[Initiating new table $newTableName creation (or updating if it exists) with the same schema as in $tableName]"

# Create the new Sentinel table
$response = Invoke-AzRestMethod -Path "$resourceId/tables/${newTableName}?api-version=2023-01-01-preview" -Method PUT -Payload $tableParamsJson

# Check if the response contains StatusCode
if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 202) {
    Write-Host "[Success] Table '$newTableName' created successfully with status code: $($response.StatusCode)" -ForegroundColor Green
}
else {
    # Output error details if the creation failed
    Write-Host "[Error] Failed to create table '$newTableName'. Status code: $($response.StatusCode)" -ForegroundColor Red
    
    # Convert Content from JSON string to PowerShell object
    $content = $response.Content | ConvertFrom-Json

    # Check if the error object is present and output the message
    if ($content.error) {
        Write-Host "[Error] Code: $($content.error.code)" -ForegroundColor Red
        Write-Host "[Error] Message: $($content.error.message)" -ForegroundColor Red
    }
    else {
        Write-Host "[Error] No detailed error information available." -ForegroundColor Red
    }
}

# Check if there are any columns to converted to string and output the transformation KQL
if ($StringList) {
    $extendParts = ""
    foreach ($col in $StringList) {
        $newCol = $col + "_str"
        $extendParts += "$newCol = tostring($col), "
    }
    $transformKql = "source | extend $extendParts"
    $transformKql = $transformKql.Substring(0, $transformKql.Length - 2)
    Write-Host ""
    Write-Host "NOTICE: There were Dynamic columns in the table and they were converted to String (as requested). Please include this in the DCR:"
    Write-Host "`"transformKql`": `"$transformKql`""
}
