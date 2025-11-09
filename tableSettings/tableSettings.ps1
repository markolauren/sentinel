<#
.SYNOPSIS
    Set the ingestion plan (Analytics, Basic, or Auxiliary/Datalake) and optionally configure total retention (days) 
    for one or more tables in a Log Analytics / Sentinel workspace.

.DESCRIPTION
    Use this script to update the ingestion plan (Analytics, Basic, or Auxiliary/Datalake)
    for one or more tables in a Log Analytics / Sentinel workspace. The script can be run
    interactively (it will prompt for missing values) or non-interactively by passing the
    parameters shown below.

    Parameters:
        -FullResourceId : Full resource ID of the Log Analytics / Sentinel workspace.
        -Table          : One or more table names to update. Provide as comma-separated list.
        -Plan           : Plan to set (Analytics, Basic, Auxiliary/Datalake). If not provided, user will be prompted.
        -TotalRetention : (Optional) Total retention in days. If not provided, it will not be prompted nor modified.

.PREREQUISITES
    This script must be run in Azure Cloud Shell 
    OR
    You must have the Azure CLI installed locally (https://docs.microsoft.com/cli/azure/install-azure-cli)
    and be authenticated (run `az login` before executing this script).

.SHORTCUTS
    This script supports single-token "shortcut" table groups when the -Table parameter
    contains exactly one token (case-insensitive). The token will be expanded to a
    predefined set of table names:

        MDI  -> IdentityLogonEvents, IdentityQueryEvents, IdentityDirectoryEvents
        MDA  -> CloudAppEvents
        MDO  -> EmailEvents, EmailUrlInfo, EmailAttachmentInfo, EmailPostDeliveryEvents, UrlClickEvents
        MDE  -> DeviceInfo, DeviceNetworkInfo, DeviceProcessEvents, DeviceNetworkEvents,
                DeviceFileEvents, DeviceRegistryEvents, DeviceLogonEvents,
                DeviceImageLoadEvents, DeviceEvents, DeviceFileCertificateInfo
        XDR  -> Expands to all tables from MDI, MDA, MDO and MDE

    Notes:
        Shortcut matching is case-insensitive and only applied when a single token
        is supplied. If you pass multiple table names or a comma-separated list,
        the script treats them as explicit table names.

.EXAMPLE
    .\tableSettings.ps1 -FullResourceId <FullResourceId> -Table Syslog, CommonSecurityLog -Plan Datalake -TotalRetention 365

#>

param(
    [string] $FullResourceId,
    [string[]] $Table,
    [string] $Plan,
    [int] $TotalRetention = 0  # optional; default 0 = not specified. If >0 it will be sent as totalRetentionInDays
)

Write-Host ""
Write-Host " +========================+" -ForegroundColor Green
Write-Host " | tableSettings.ps1 v1.0 |" -ForegroundColor Green
Write-Host " +========================+" -ForegroundColor Green
Write-Host ""

if (-not $FullResourceId) {
    $FullResourceId = Read-Host "Full workspace resourceId (e.g. /subscriptions/<sub>/resourceGroups/<rg>/providers/microsoft.operationalinsights/workspaces/<name>)"
}

# normalize and parse FullResourceId
if (-not $FullResourceId) {
    Write-Error "FullResourceId parameter is required."
    exit 2
}
if (-not $FullResourceId.StartsWith("/")) { $FullResourceId = "/$FullResourceId" }

$pattern = '^/subscriptions/(?<sub>[^/]+)/resourcegroups/(?<rg>[^/]+)/providers/microsoft\.operationalinsights/workspaces/(?<ws>[^/]+)$'
$m = [regex]::Match($FullResourceId, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
if (-not $m.Success) {
    Write-Error "FullResourceId does not match expected workspace format. Example: /subscriptions/<sub>/resourceGroups/<rg>/providers/microsoft.operationalinsights/workspaces/<name>"
    exit 3
}

# Prompt for table(s) if not provided; accept multiple names separated by comma
if (-not $Table -or $Table.Count -eq 0) {
    $input = Read-Host "Tables to modify, separate with comma (e.g. Syslog, CommonSecurityLog)"
    if ($input) {
        $Table = ($input -split '[,\s]+') | Where-Object { $_ -ne '' }
    }
}

# If Table was provided as a single comma separated string, normalize it
if ($Table -and ($Table.Count -eq 1) -and ($Table[0] -match '[,\s]')) {
    $Table = ($Table[0] -split '[,\s]+') | Where-Object { $_ -ne '' }
}

# Ensure $Table is an array and trim values
if ($Table) {
    if ($Table -isnot [System.Array]) { $Table = @($Table) }
    $Table = $Table | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
} else {
    Write-Host "No table names provided; nothing to do." -ForegroundColor Yellow
    exit 0
}

# If exactly one table token is supplied and it matches a known shorthand code,
# expand it to the corresponding full set of table names. Supported shorthands (case-insensitive):
#   MDI -> IdentityLogonEvents, IdentityQueryEvents, IdentityDirectoryEvents
#   MDA -> CloudAppEvents
#   MDO -> EmailEvents, EmailUrlInfo, EmailAttachmentInfo, EmailPostDeliveryEvents, UrlClickEvents
#   MDE -> DeviceInfo, DeviceNetworkInfo, DeviceProcessEvents, DeviceNetworkEvents,
#          DeviceFileEvents, DeviceRegistryEvents, DeviceLogonEvents, DeviceImageLoadEvents,
#          DeviceEvents, DeviceFileCertificateInfo
#   XDR -> all of the above
# Any other single token is left as-is.
if ($Table.Count -eq 1) {
    switch ($Table[0].Trim().ToUpper()) {
        'MDI' {
            $Table = @(
                'IdentityLogonEvents',
                'IdentityQueryEvents',
                'IdentityDirectoryEvents'
            )
            break
        }
        'MDA' {
            $Table = @('CloudAppEvents')
            break
        }
        'MDO' {
            $Table = @(
                'EmailEvents',
                'EmailUrlInfo',
                'EmailAttachmentInfo',
                'EmailPostDeliveryEvents',
                'UrlClickEvents'
            )
            break
        }
        'MDE' {
            $Table = @(
                'DeviceInfo',
                'DeviceNetworkInfo',
                'DeviceProcessEvents',
                'DeviceNetworkEvents',
                'DeviceFileEvents',
                'DeviceRegistryEvents',
                'DeviceLogonEvents',
                'DeviceImageLoadEvents',
                'DeviceEvents',
                'DeviceFileCertificateInfo'
            )
            break
        }
        'XDR' {
            $Table = @(
                # Identity (MDI)
                'IdentityLogonEvents',
                'IdentityQueryEvents',
                'IdentityDirectoryEvents',
                # Cloud App (MDA)
                'CloudAppEvents',
                # Email (MDO)
                'EmailEvents',
                'EmailUrlInfo',
                'EmailAttachmentInfo',
                'EmailPostDeliveryEvents',
                'UrlClickEvents',
                # Device (MDE)
                'DeviceInfo',
                'DeviceNetworkInfo',
                'DeviceProcessEvents',
                'DeviceNetworkEvents',
                'DeviceFileEvents',
                'DeviceRegistryEvents',
                'DeviceLogonEvents',
                'DeviceImageLoadEvents',
                'DeviceEvents',
                'DeviceFileCertificateInfo'
            )
            # normalize & remove any duplicates while preserving order
            $Table = $Table | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' } | Select-Object -Unique
            break
        }
        default { 
            # leave $Table as-is for any other single token
        }
    }
}

# Prompt for Plan if not provided
if (-not $Plan) {
    $Plan = Read-Host "Plan to set (Analytics, Basic, or Auxiliary/Datalake) [default: Datalake]"
    if (-not $Plan -or $Plan -eq "") { $Plan = "Datalake" }
}

# validate and normalize $Plan (allow mixed casing; final form: LeadingCapital + remaining lower-case)
$validPlans = @{
    'analytics' = 'Analytics'
    'basic'     = 'Basic'
    'auxiliary' = 'Auxiliary'
    'datalake'  = 'Datalake'
}

# ensure $Plan is a trimmed string
if ($Plan) { $planInput = $Plan.Trim() } else { $planInput = '' }

$planKey = $planInput.ToLower()

if (-not $validPlans.ContainsKey($planKey)) {
    # If the caller passed -Plan on the command line, fail fast for invalid value
    if ($PSBoundParameters.ContainsKey('Plan')) {
        Write-Error "Invalid Plan value '$Plan'. Valid values: Analytics, Basic, Auxiliary, Datalake."
        exit 4
    }

    # interactive prompt until a valid value is provided (default Datalake)
    do {
        $resp = Read-Host "Plan to set (Analytics, Basic, or Auxiliary/Datalake) [default: Datalake]"
        if (-not $resp -or $resp.Trim() -eq '') { $resp = 'Datalake' }
        $planKey = $resp.Trim().ToLower()
    } while (-not $validPlans.ContainsKey($planKey))
}

# set $Plan to the normalized form (Leading capital + lower-case remainder)
$Plan = $validPlans[$planKey]

# treat "Datalake" as the same as "Auxiliary", because in Log analytics and in API it's called Auxiliary
if ($Plan -eq 'Datalake') {
    $PlanInAPI = 'Auxiliary'
} else {
    $PlanInAPI = $Plan
}

$apiVersion = "2023-01-01-preview"

# Extract subscriptionId, resourceGroup, workspaceName from FullResourceId
$subscriptionId = $m.Groups['sub'].Value
$resourceGroup  = $m.Groups['rg'].Value
$workspaceName  = $m.Groups['ws'].Value

# Get access token using Azure CLI
$token = az account get-access-token --resource https://management.azure.com/ | ConvertFrom-Json

# Prepare request body
$properties = @{
    plan = $PlanInAPI
}
# include TotalRetention only if the caller supplied it (exposed as totalRetentionInDays in API)
if ($TotalRetention -ne 0) {
    $properties.totalRetentionInDays = $TotalRetention
}
$body = @{
    properties = $properties
} | ConvertTo-Json -Depth 3

# Set headers
$headers = @{
    Authorization = "Bearer $($token.accessToken)"
    'Content-Type' = "application/json"
}

# Send the PATCH request for each table supplied
Write-Host ""
Write-Host ("Workspace: {0} (rg: {1}, subscription: {2})" -f $workspaceName, $resourceGroup, $subscriptionId) -ForegroundColor Cyan
$retentionText = ""
if ($TotalRetention -ne 0) {
    $retentionText = ", Total retention: $TotalRetention days"
}
Write-Host ("Plan: {0}{1}" -f $Plan, $retentionText) -ForegroundColor Cyan
Write-Host ("Tables to update ({0}): {1}" -f $Table.Count, ($Table -join ', ')) -ForegroundColor Cyan
Write-Host ""
foreach ($tbl in $Table) {
    $url = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.OperationalInsights/workspaces/$workspaceName/tables/$tbl`?api-version=$apiVersion"

    try {
        $response = Invoke-RestMethod -Method Patch -Uri $url -Headers $headers -Body $body
        Write-Host ("Table '{0}' updated successfully." -f $tbl) -ForegroundColor Green
    } catch {
        Write-Host ("Failed to update table plan for '{0}': {1}" -f $tbl, $_.Exception.Message) -ForegroundColor Red
    }
}
Write-Host ""
Write-Host ""
