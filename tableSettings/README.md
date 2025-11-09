# 💡 tableSettings.ps1 (v1.0)

**Author:** Marko Lauren

<img width="1092" height="291" alt="image" src="https://github.com/user-attachments/assets/1c5d0c83-9d01-4d48-b76e-065f7e7eb39c" />

## Purpose

`tableSettings.ps1` is a PowerShell utility to update the ingestion plan (Analytics, Basic, or Auxiliary/DataLake) and optionally set total retention (days) for one or more tables in a Log Analytics / Sentinel workspace. It supports interactive prompts or fully non-interactive command-line usage.

This is useful when you need to:
- change ingestion plans across tables (for cost/architecture reasons),
- apply consistent retention settings,
- or update many tables programmatically.

## Key Features

- Set ingestion plan for one or many tables (Analytics, Basic, Auxiliary/DataLake).  
- Optionally configure total retention  
- Interactive prompts when parameters are omitted, or full CLI automation.  
- Support for comma-separated table lists and single-token shortcuts (MDI/MDA/MDO/MDE/XDR).  
- Requires to be run in Azure Cloud Shell, or locally when Azure CLI installed (and `az login` is done).

## Quick Start

1. Open PowerShell (Azure Cloud Shell or local PowerShell with Azure CLI).
2. If running locally, authenticate:
```powershell
az login
```
3. Run interactively:
```powershell
.\tableSettings.ps1
```
You will be prompted for the workspace resource ID, table(s) and plan.

## Usage

Provide all parameters on the command line for automation.

Basic syntax:
```powershell
.\tableSettings.ps1 -FullResourceId <RESOURCE_ID> -Table <Table1>, <Table2>,... -Plan <Analytics|Basic|Auxiliary|Datalake> -TotalRetention <Days>
```

Examples:
```powershell
# Set multiple explicit tables to Datalake with 365 days total retention
.\tableSettings.ps1 -FullResourceId "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myRG/providers/microsoft.operationalinsights/workspaces/myWS" -Table Syslog,CommonSecurityLog -Plan Datalake -TotalRetention 365

# Use a single-token shortcut (expands to multiple tables)
.\tableSettings.ps1 -FullResourceId "/subscriptions/.../workspaces/myWS" -Table MDI -Plan Analytics

# Single table, set to Datalake and don't change total retention (omit TotalRetention)
.\tableSettings.ps1 -FullResourceId "/subscriptions/.../workspaces/myWS" -Table Syslog -Plan Datalake
```

Notes:
- `Datalake` is treated as `Auxiliary` in the API (the script maps it automatically).  
- `TotalRetention` is optional. If omitted (or set to `0`), the script will not modify total retention.

## Table Shortcuts

If you supply exactly one token to `-Table`, the script will expand the following shortcuts (case-insensitive):

- `MDI` → IdentityLogonEvents, IdentityQueryEvents, IdentityDirectoryEvents  
- `MDA` → CloudAppEvents  
- `MDO` → EmailEvents, EmailUrlInfo, EmailAttachmentInfo, EmailPostDeliveryEvents, UrlClickEvents  
- `MDE` → DeviceInfo, DeviceNetworkInfo, DeviceProcessEvents, DeviceNetworkEvents, DeviceFileEvents, DeviceRegistryEvents, DeviceLogonEvents, DeviceImageLoadEvents, DeviceEvents, DeviceFileCertificateInfo  
- `XDR` → expands to the union of MDI, MDA, MDO and MDE

If you pass multiple tokens or a comma-separated list, entries are treated as explicit table names.

## Parameters

- `-FullResourceId` : Full Azure resource ID of the Log Analytics / Sentinel workspace. Example:
  ```
  /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP>/providers/Microsoft.OperationalInsights/workspaces/<WORKSPACE_NAME>
  ```
- `-Table` : One or more table names to update (supports shortcuts when exactly one token is supplied).
- `-Plan` : Plan to set — `Analytics`, `Basic`, `Auxiliary`, or `Datalake` (mapping applied).
- `-TotalRetention` (optional) : Total retention in days. Default `0` = not specified / not changed.

---
