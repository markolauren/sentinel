# 💡 tableReplicator.ps1 (v1.0)

**Author:** Marko Lauren

**Credits:** The idea for this script originated from Sergio Medina Vallejo.

## Purpose

`tableReplicator.ps1` is a PowerShell script for Microsoft Sentinel BCDR (Business Continuity and Disaster Recovery). It discovers all custom tables (`_CL`) in a source Sentinel workspace and recreates them — including schema, plan type, and retention settings — in a destination workspace, one table at a time. This is the foundation for maintaining an active-active mirrored Sentinel environment across two regions.

## Key Features

- **Full custom table discovery:** Automatically finds all `_CL` tables in the source workspace via the Log Analytics REST API.
- **Schema + plan + retention replication:** Copies column definitions, table plan (Analytics / Auxiliary / Basic), and retention settings to the destination.
- **Interactive confirmation:** Lists all discovered tables and asks for confirmation before writing anything to the destination.
- **Table-by-table processing:** Progress and errors are visible in real time; a failure on one table does not stop the rest.
- **Dynamic column handling:** Dynamic-typed columns that are incompatible with Auxiliary/Basic plans are skipped with a clear warning.
- **Classic table detection:** Tables of the Classic sub-type (created via the legacy MMA / Data Collector API) cannot be replicated through the Tables API and are automatically skipped with a warning. They are listed separately so you know what was excluded.
- **Override plan:** Use `-IgnorePlan` to force all destination tables to Analytics, regardless of the source plan.
- **Override retention:** Use `-IgnoreRetention` to skip retention settings and let the destination workspace defaults apply.
- **Interactive & command-line modes:** Provide parameters on the command line or be prompted interactively.
- **Tenant selection:** Use `-TenantId` for authentication outside Azure Cloud Shell.

## Usage

### 1. Obtain Resource IDs

To get the full resource ID for a workspace, go to your Log Analytics Workspace in the Azure portal and choose **JSON View** in the Overview blade, or open **Properties**. Copy the full resource ID shown at the top.

### 2. Run the Script

#### Interactive Mode

```
.\tableReplicator.ps1
```

You will be prompted for both resource IDs.

#### Command-Line Mode

```
.\tableReplicator.ps1 `
  -SourceResourceId "/subscriptions/<SRC_SUB>/resourceGroups/<SRC_RG>/providers/Microsoft.OperationalInsights/workspaces/<SRC_WS>" `
  -DestinationResourceId "/subscriptions/<DST_SUB>/resourceGroups/<DST_RG>/providers/Microsoft.OperationalInsights/workspaces/<DST_WS>"
```

With explicit tenant authentication (outside Cloud Shell):

```
.\tableReplicator.ps1 `
  -TenantId <YOUR_TENANT_ID> `
  -SourceResourceId "/subscriptions/<SRC_SUB>/resourceGroups/<SRC_RG>/providers/Microsoft.OperationalInsights/workspaces/<SRC_WS>" `
  -DestinationResourceId "/subscriptions/<DST_SUB>/resourceGroups/<DST_RG>/providers/Microsoft.OperationalInsights/workspaces/<DST_WS>"
```

With plan and retention overrides:

```
.\tableReplicator.ps1 `
  -SourceResourceId "/subscriptions/<SRC_SUB>/resourceGroups/<SRC_RG>/providers/Microsoft.OperationalInsights/workspaces/<SRC_WS>" `
  -DestinationResourceId "/subscriptions/<DST_SUB>/resourceGroups/<DST_RG>/providers/Microsoft.OperationalInsights/workspaces/<DST_WS>" `
  -IgnorePlan -IgnoreRetention
```

### Parameters

- `-SourceResourceId` : Full Azure Resource ID of the source Sentinel / Log Analytics workspace.
- `-DestinationResourceId` : Full Azure Resource ID of the destination Sentinel / Log Analytics workspace.
- `-TenantId` : (Optional) Azure tenant ID for authentication. Required only when not running in Azure Cloud Shell.
- `-IgnorePlan` : (Optional) Force all destination tables to be created as Analytics plan, ignoring the source table plan.
- `-IgnoreRetention` : (Optional) Do not carry over retention settings; destination tables use the workspace default retention.

---
