<#
.SYNOPSIS
    Replicates all custom (_CL) tables from a source Microsoft Sentinel workspace to a destination workspace.

.NOTES
    Author:  Marko Lauren
    Credits: Original idea by Sergio Medina Vallejo

.DESCRIPTION
    This script supports Sentinel BCDR (Business Continuity and Disaster Recovery) by discovering all custom
    tables in a source Log Analytics / Sentinel workspace and recreating them — including schema, plan, and
    retention settings — in a destination workspace, one table at a time.

    The script lists all discovered custom tables and asks for confirmation before writing anything to the
    destination. Each table is processed individually so progress and errors are visible in real time.

.PARAMETER SourceResourceId
    The full resource ID of the source Sentinel / Log Analytics workspace.
    Can be found in the Log Analytics Workspace blade > JSON View > copy button.

.PARAMETER DestinationResourceId
    The full resource ID of the destination Sentinel / Log Analytics workspace.

.PARAMETER TenantId
    Azure tenant ID. Required only if not running in Azure Cloud Shell.
    Requires the Az PowerShell module to be installed.

.EXAMPLE
    .\tableReplicator.ps1 -SourceResourceId "/subscriptions/<SRC_SUB>/resourceGroups/<SRC_RG>/providers/Microsoft.OperationalInsights/workspaces/<SRC_WS>" `
                          -DestinationResourceId "/subscriptions/<DST_SUB>/resourceGroups/<DST_RG>/providers/Microsoft.OperationalInsights/workspaces/<DST_WS>"

.EXAMPLE
    .\tableReplicator.ps1 -TenantId YOUR_TENANT_ID `
                          -SourceResourceId "/subscriptions/<SRC_SUB>/resourceGroups/<SRC_RG>/providers/Microsoft.OperationalInsights/workspaces/<SRC_WS>" `
                          -DestinationResourceId "/subscriptions/<DST_SUB>/resourceGroups/<DST_RG>/providers/Microsoft.OperationalInsights/workspaces/<DST_WS>"

#>

param (
    [string]$TenantId,
    [switch]$IgnorePlan,
    [switch]$IgnoreRetention,

    [ValidateScript({
            if ($_ -match '^/subscriptions/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/resourcegroups/[a-zA-Z0-9._\-]+/providers/microsoft.operationalinsights/workspaces/[a-zA-Z0-9_\-]+$') {
                $true
            }
            else {
                throw "`n'$_' doesn't look like a valid full resource ID."
            }
        })]
    [string]$SourceResourceId,

    [ValidateScript({
            if ($_ -match '^/subscriptions/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/resourcegroups/[a-zA-Z0-9._\-]+/providers/microsoft.operationalinsights/workspaces/[a-zA-Z0-9_\-]+$') {
                $true
            }
            else {
                throw "`n'$_' doesn't look like a valid full resource ID."
            }
        })]
    [string]$DestinationResourceId
)

# ── Banner ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host " +==========================+" -ForegroundColor Green
Write-Host " | tableReplicator.ps1 v1.0 |" -ForegroundColor Green
Write-Host " +==========================+" -ForegroundColor Green
Write-Host ""

# ── Helper: validated prompt ─────────────────────────────────────────────────
function PromptForResourceId {
    param ([string]$promptMessage)

    $resourceIdPattern = '^/subscriptions/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/resourcegroups/[a-zA-Z0-9._\-]+/providers/microsoft.operationalinsights/workspaces/[a-zA-Z0-9_\-]+$'

    while ($true) {
        $value = Read-Host -Prompt $promptMessage
        if ($value -match $resourceIdPattern) {
            return $value
        }
        Write-Host "[Error] That doesn't look like a valid resource ID." -ForegroundColor Red
        Write-Host "        Expected format: /subscriptions/<guid>/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<ws>" -ForegroundColor Red
    }
}

# ── Authentication ────────────────────────────────────────────────────────────
if ($TenantId) {
    try {
        Connect-AzAccount -TenantId $TenantId -ErrorAction Stop
    }
    catch {
        Write-Host "[Error] Failed to connect to Azure: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# ── Resolve missing resource IDs ──────────────────────────────────────────────
if (-not $SourceResourceId) {
    $SourceResourceId = PromptForResourceId "Enter Source Sentinel Resource ID"
}
if (-not $DestinationResourceId) {
    $DestinationResourceId = PromptForResourceId "Enter Destination Sentinel Resource ID"
}

# ── Phase 1: Discover custom tables in source workspace ───────────────────────
Write-Host "[Querying custom tables in source workspace...]"

$listResponse = Invoke-AzRestMethod -Path "$SourceResourceId/tables?api-version=2023-01-01-preview" -Method GET

if ($listResponse.StatusCode -ne 200) {
    Write-Host "[Error] Failed to list tables from source workspace. Status code: $($listResponse.StatusCode)" -ForegroundColor Red
    $listContent = $listResponse.Content | ConvertFrom-Json
    if ($listContent.error) {
        Write-Host "[Error] $($listContent.error.code): $($listContent.error.message)" -ForegroundColor Red
    }
    exit 1
}

$allTables = ($listResponse.Content | ConvertFrom-Json).value
$customTables = $allTables | Where-Object { $_.name -like "*_CL" } | Sort-Object { $_.name }
$classicTables = $customTables | Where-Object { $_.properties.schema.tableSubType -eq "Classic" }
$replicateTables = $customTables | Where-Object { $_.properties.schema.tableSubType -ne "Classic" }

if (-not $replicateTables -or $replicateTables.Count -eq 0) {
    if ($classicTables.Count -gt 0) {
        Write-Host "[Warning] Only Classic-type custom tables found -- these cannot be replicated via the Tables API." -ForegroundColor Yellow
    }
    else {
        Write-Host "[Warning] No custom tables (_CL) found in the source workspace. Nothing to replicate." -ForegroundColor Yellow
    }
    exit 0
}

# ── Phase 2: Show table list and ask for confirmation ─────────────────────────
$total = $replicateTables.Count
Write-Host ""
Write-Host "Found $total custom table(s) to replicate:" -ForegroundColor Cyan
Write-Host ""

Write-Host ("  {0,-50} {1,-12} {2,-15} {3}" -f "Table Name", "Plan", "Interactive", "Total Retention")
Write-Host ("  {0} {1} {2} {3}" -f ("=" * 50), ("=" * 12), ("=" * 15), ("=" * 15))
Write-Host ""

foreach ($t in $replicateTables) {
    $tProps = $t.properties
    $plan = if ($tProps.plan) { $tProps.plan } else { "Analytics" }

    $interactiveVal = if ($plan -eq "Analytics") {
        if (-not $tProps.retentionInDaysAsDefault) { "$($tProps.retentionInDays)d" } else { "ws default" }
    }
    else { "-" }

    $totalVal = if (-not $tProps.totalRetentionInDaysAsDefault) { "$($tProps.totalRetentionInDays)d" } else { "ws default" }

    Write-Host ("  {0,-50} {1,-12} {2,-15} {3}" -f $t.name, $plan, $interactiveVal, $totalVal)
}

if ($classicTables.Count -gt 0) {
    Write-Host ""
    Write-Host "  The following Classic-type tables will be SKIPPED (created via old Data Collector API / MMA):" -ForegroundColor Yellow
    foreach ($t in $classicTables) {
        Write-Host ("    {0}" -f $t.name) -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "  [1] Replicate all tables" -ForegroundColor White
Write-Host "  [2] One-by-one (confirm each table)" -ForegroundColor White
Write-Host "  [Q] Quit" -ForegroundColor White
Write-Host ""

$runMode = ""
while ($runMode -notin @("1", "2", "Q", "q")) {
    $runMode = Read-Host "Choose an option (1/2/Q)"
}

if ($runMode -in @("Q", "q")) {
    Write-Host "[Aborted]" -ForegroundColor Yellow
    exit 0
}

# ── Phase 3: Replicate table by table ─────────────────────────────────────────
if ($IgnorePlan) { Write-Host "[IgnorePlan] All tables will be created as Analytics plan." -ForegroundColor Cyan }
if ($IgnoreRetention) { Write-Host "[IgnoreRetention] Retention settings will not be carried over." -ForegroundColor Cyan }
Write-Host ""
$successCount = 0
$failCount = 0
$i = 0

foreach ($table in $replicateTables) {
    $i++
    $tableName = $table.name
    $props = $table.properties
    $plan = if ($props.plan) { $props.plan } else { "Analytics" }
    $sourcePlan = $plan
    if ($IgnorePlan) { $plan = "Analytics" }

    Write-Host ""
    Write-Host "[$i/$total] $tableName  (Plan: $plan)"

    if ($runMode -eq "2") {
        $tableConfirm = Read-Host "  Replicate this table? (Y/N/Q to quit)"
        if ($tableConfirm -match '^[Qq]') {
            Write-Host "[Stopped by user]" -ForegroundColor Yellow
            break
        }
        if ($tableConfirm -notmatch '^[Yy]') {
            Write-Host "  [Skipped]" -ForegroundColor DarkGray
            continue
        }
    }

    # ── Column processing ──────────────────────────────────────────────────────
    $sourceColumns = $props.schema.columns

    $processedColumns = $sourceColumns | Where-Object {
        # Filter out workspace-internal system columns and _-prefixed system fields
        $_.name -notin @("TenantId", "Type", "Id", "MG") -and
        $_.name -notlike "_*"
    } | ForEach-Object {
        $colName = $_.name
        $colType = $_.type

        # Auxiliary plan: bool must be expressed as boolean
        if ($plan -eq "Auxiliary" -and $colType -eq "bool") {
            $colType = "boolean"
        }

        # Analytics plan: boolean must be expressed as bool (reverse of above; matters when source was Auxiliary)
        if ($plan -eq "Analytics" -and $colType -eq "boolean") {
            $colType = "bool"
        }

        # Auxiliary/Basic plan: dynamic columns are not supported — skip with warning
        if ($plan -in @("Auxiliary", "Basic") -and $colType -eq "dynamic") {
            Write-Host "  [SKIPPING column '$colName' -- dynamic type is not supported by $plan plan]" -ForegroundColor Yellow
            return  # skip this column (ForEach-Object continue)
        }

        # Emit only name and type (strip isHidden, description, etc.)
        @{
            "name" = $colName
            "type" = $colType
        }
    }

    # ── Build table payload ────────────────────────────────────────────────────
    $tableParams = @{
        "properties" = @{
            "plan"   = $plan
            "schema" = @{
                "name"    = $tableName
                "columns" = @($processedColumns)
            }
        }
    }

    # Analytics: carry over interactive retention only if source was also Analytics and value is not the workspace default
    if (-not $IgnoreRetention -and $sourcePlan -eq "Analytics" -and -not $props.retentionInDaysAsDefault) {
        $tableParams.properties.retentionInDays = $props.retentionInDays
    }

    # All plans: carry over total retention only if explicitly set (not defaulting to retentionInDays)
    if (-not $IgnoreRetention -and -not $props.totalRetentionInDaysAsDefault) {
        $tableParams.properties.totalRetentionInDays = $props.totalRetentionInDays
    }

    $tableParamsJson = $tableParams | ConvertTo-Json -Depth 10

    # ── PUT to destination workspace ───────────────────────────────────────────
    $putResponse = Invoke-AzRestMethod -Path "$DestinationResourceId/tables/${tableName}?api-version=2023-01-01-preview" -Method PUT -Payload $tableParamsJson

    if ($putResponse.StatusCode -eq 200 -or $putResponse.StatusCode -eq 202) {
        Write-Host "  [OK] $tableName created/updated successfully (status $($putResponse.StatusCode))" -ForegroundColor Green
        $successCount++
    }
    else {
        Write-Host "  [Error] Failed to create '$tableName'. Status code: $($putResponse.StatusCode)" -ForegroundColor Red
        $errContent = $putResponse.Content | ConvertFrom-Json
        if ($errContent.error) {
            Write-Host "  [Error] $($errContent.error.code): $($errContent.error.message)" -ForegroundColor Red
        }
        $failCount++
    }
}

# ── Phase 4: Summary ──────────────────────────────────────────────────────────
Write-Host ""
if ($failCount -eq 0) {
    Write-Host "Completed: $successCount/$total tables replicated successfully." -ForegroundColor Green
}
else {
    Write-Host "Completed: $successCount succeeded, $failCount failed out of $total tables." -ForegroundColor Yellow
}
