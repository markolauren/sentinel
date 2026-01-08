# Microsoft 365 Audit Connectors (General + DLP) for Microsoft Sentinel v1.0.0

**Author**: Marko Lauren

This solution provides **two codeless connectors (CCF)** for ingesting Microsoft 365 audit logs from the Office 365 Management Activity API into Microsoft Sentinel:
- **Microsoft 365 Audit.General** - General audit logs (29 specialty workloads)
- **Microsoft 365 Audit.DLP** - Data Loss Prevention events

## Overview

These connectors use the **Office 365 Management Activity API** to retrieve Microsoft 365 audit logs into a shared **304-column schema** covering **30 specialty workload types**:

- **Audit.General connector**: 29 specialty workloads (Copilot, Power BI, Viva suite, Security & Compliance, eDiscovery, Sentinel platform, etc.)
- **Audit.DLP connector**: Data loss prevention (DLP) events in Microsoft Purview available for Exchange Online, Endpoint(devices), and SharePoint and OneDrive.

**Schema Design:** This connector follows the official [Office 365 Management Activity API Schema](https://learn.microsoft.com/en-us/office/office-365-management-api/office-365-management-activity-api-schema) as documented by Microsoft. All field names, types, and structures are mapped directly from the API schema to ensure compatibility and accuracy.

## Quickstart

**Get started in 3 simple steps:**

1. **Deploy the solution** - Click the button below to deploy both connectors and infrastructure to your Sentinel workspace:

   [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmarkolauren%2Fsentinel%2Frefs%2Fheads%2Fmain%2FM365AuditGeneralAndDLPSolution%2FM365AuditGeneralAndDLPSolution.json)

2. **Open the connector pages** - After deployment completes, navigate to Sentinel → Data connectors and search for:
   - "Microsoft 365 Audit.General" 
   - "Microsoft 365 Audit.DLP"

3. **Follow the setup instructions** - Each connector page provides step-by-step instructions for:
   - Creating an Entra ID app registration
   - Configuring API permissions
   - Subscribing to the content type
   - Entering your credentials

Data will start flowing within 30-60 minutes after completing the setup!

> **Note**: If you need very detailed guidance, jump to [Setup](#setup) section.

## Content Types Coverage

The Office 365 Management Activity API organizes audit data into different content types:
- **Audit.AzureActiveDirectory** - Azure AD/Entra ID events (sign-ins, directory changes)
- **Audit.Exchange** - Exchange Online events (email, mailbox access)
- **Audit.SharePoint** - SharePoint/OneDrive events (file operations)
- **Audit.General** ✅ - All other Microsoft 365 workloads not in the above (covered by this solution)
- **DLP.All** ✅ - DLP events only for all workloads (covered by this solution)

### Audit.General Connector Scope

**✅ Included (29 specialty workload schemas):**
- **Copilot & AI**: Microsoft 365 Copilot interactions, AI Agent operations, Copilot scheduled prompts
- **Power Platform**: Power BI (dashboards, datasets, reports), Microsoft Forms
- **Collaboration**: Viva Engage (Yammer), Project for the web
- **Viva Suite**: Viva Insights, Viva Goals, Viva Glint, Viva Pulse
- **Security & Compliance**: Microsoft Defender for Office 365, Attack Simulation & Training, User Submissions, Automated Investigation & Response (AIR), Hygiene Events, Quarantine, Security & Compliance Alerts, Security & Compliance Center operations
- **Information Protection**: MIP Label, Encrypted Message Portal
- **eDiscovery**: eDiscovery case management, search, export, and hold operations
- **Cloud Management**: Backup/Restore operations (Policy, Task, Item schemas)
- **Security Tools**: Microsoft Edge WebContentFiltering
- **Microsoft Sentinel**: Sentinel Data Lake operations (Notebooks, Jobs, KQL queries, Lake onboarding, AI Tools, Graph operations)
- **Infrastructure**: Places Directory, Data Center Security (Base & Cmdlet schemas)

**❌ Excluded (have dedicated Microsoft Sentinel connectors or filtered):**
- Microsoft Teams (filtered RecordType=25, dedicated connector exists)
- Dynamics 365 (filtered RecordType=21 & 278, dedicated connector exists)
- Microsoft Purview Information Protection (filtered RecordType=71,72,75,82,83,84,93,94,95,96,97, dedicated connector exists)
- SharePoint/OneDrive (dedicated connector exists)
- Exchange (dedicated connector exists)
- Microsoft Entra ID (dedicated connector exists)

### Audit.DLP Connector Scope

**✅ Included (All DLP events):**
- **RecordType 11** - ComplianceDLPSharePoint (DLP events in SharePoint and OneDrive)
- **RecordType 13** - ComplianceDLPExchange (DLP events in Exchange via Unified DLP Policy)
- **RecordType 33** - ComplianceDLPSharePointClassification (DLP classification in SharePoint)
- **RecordType 63** - DLPEndpoint (Endpoint DLP events)
- **RecordType 99** - OnPremisesFileShareScannerDlp (Scanning for sensitive data on file shares)
- **RecordType 100** - OnPremisesSharePointScannerDlp (Scanning for sensitive data in SharePoint)
- **RecordType 107** - ComplianceDLPExchangeClassification (Exchange DLP classification events)
- **RecordType 187** - PowerPlatformAdminDlp (Microsoft Power Platform DLP - Preview)

## Polling Behavior

**Polling Interval:** The connector polls the Office 365 Management API every **5 minutes** by default.

### Changing the Polling Interval

To modify the polling interval (e.g., to 15 minutes), edit the `M365AuditGeneralAndDLPSolution.json` template **before deployment**:

1. Open the template file in a text editor
2. Search for `"queryWindowInMin": 5` (appears twice - once for each connector)
3. Change the value from `5` to your desired interval in minutes (e.g., `15`)
4. Save the file and deploy using the modified template

**Example:**
```json
"request": {
    "apiEndpoint": "...",
    "httpMethod": "GET",
    "rateLimitQPS": 10,
    "queryWindowInMin": 15,
    "queryTimeFormat": "yyyy-MM-ddTHH:mm:ss",
    ...
}
```

**Note:** Microsoft recommends polling intervals between 5-60 minutes. Shorter intervals provide more real-time data but consume more API quota; longer intervals reduce API calls but delay data ingestion.

### API Rate Limiting

The connector uses `"rateLimitQPS": 10` to control the maximum number of API requests per second when fetching audit data. 

**When it matters:** During each polling cycle, if there are multiple content blobs to fetch, this setting prevents overwhelming the API. The Office 365 Management API limits are **2,000 requests per minute per app** (≈33 req/sec), so the default of 10 req/sec is conservative and safe.

**To change:** Edit the same locations as `queryWindowInMin`, Increase to 20-30 for faster data ingestion if you have high log volume; decrease to 5 if experiencing throttling errors.

## Data Schema

Both connectors ingest data into the **shared** `M365AuditGeneral_CL` custom table with **304 columns** covering **30 workload schemas** (29 from Audit.General + 1 DLP schema).

### Core Common Fields (14 fields)

| Field | Type | Description |
|-------|------|-------------|
| TimeGenerated | datetime | The time when the event was ingested into Sentinel |
| Id | string | Unique identifier for the audit record |
| RecordType | int | The type of operation indicated by the record |
| CreationTime | datetime | The date and time in UTC when the user performed the activity |
| Operation | string | The name of the user or admin activity |
| UserId | string | The UPN of the user who performed the action |
| Workload | string | The Microsoft 365 service (e.g., PowerBI, MicrosoftForms, Yammer) |
| ClientIP | string | The IP address of the device that was used |
| ResultStatus | string | Indicates whether the action was successful |
| ObjectId | string | The name/path of the object that was modified |
| UserType | int | The type of user that performed the operation |
| UserKey | string | An alternative ID for the user |
| OrganizationId | string | The GUID for your Microsoft 365 tenant |
| Scope | string | Whether the event was from hosted M365 or on-premises |

### Workload-Specific Fields (290 additional fields)

The schema includes dedicated typed columns for 30 specialty workloads:

- **Copilot & AI Agents** (10 fields): CopilotEventData (dynamic), AgentId, AgentName, AgentType, etc.
- **Project for the web** (3 fields): ProjectEntity, ProjectAction, OnBehalfOfResId
- **eDiscovery** (19 fields): Case management, searches, holds, review sets, exports, queries
- **Security & Compliance Center** (8 fields): Cmdlet operations, parameters, version info
- **Security & Compliance Alerts** (12 fields): Alert management, policies, statuses, entities
- **Viva Engage (Yammer)** (16 fields): Messages, files, groups, network operations
- **Microsoft Defender for Office 365** (27 fields): Threat detection, email verdicts, attachments, delivery actions
- **Attack Simulation & Training** (15 fields): Campaigns, techniques, user training events
- **Submission** (12 fields): User and admin submissions, triage, notifications
- **Automated Investigation & Response (AIR)** (20 fields): Investigation details, actions, approvals, entities
- **Hygiene Events** (5 fields): Listing/delisting events and audit information
- **Power BI** (10 fields): Apps, dashboards, datasets, reports, workspaces, sharing
- **Viva Insights** (3 fields): User role and operation details
- **Quarantine** (4 fields): Request types, sources, release operations
- **Microsoft Forms** (6 fields): Form management, user types, activity parameters
- **MIP Label** (8 fields): Sensitivity labeling for email messages
- **Encrypted Message Portal** (8 fields): Message access authentication and operations
- **Reports** (1 field): Generic report operations
- **Compliance Connector** (10 fields): Third-party data connector import operations
- **SystemSync & Data Lake** (5 fields): Data store operations and exports
- **Viva Glint** (7 fields): Survey management and platform controls
- **Viva Goals** (10 fields): Organization and user activity tracking
- **Viva Pulse** (3 fields): EventName, PulseId, EventDetails
- **Backup/Restore** (17 fields): Policy, task, and item-level backup/restore operations
- **Edge WebContentFiltering** (3 fields): URL browsing and domain tracking
- **Copilot Scheduled Prompts** (4 fields): Scheduled automation execution
- **Places Directory** (3 fields): Workplace location management
- **Data Center Security Base** (1 field): DataCenterSecurityEventType
- **Data Center Security Cmdlet** (9 fields): ElevationTime, ElevationApprover, ElevationApprovedTime, ElevationRequestId, ElevationRole, ElevationDuration, GenericInfo, StartTime, EffectiveOrganization
- **Microsoft Sentinel Data Lake** (42 fields): Notebooks, Jobs, KQL queries, AI Tools, Graph operations, lake onboarding
- **DLP (Data Loss Prevention)** (6 fields): SharePointMetaData, ExchangeMetaData, EndpointMetaData, ExceptionInfo, PolicyDetails, SensitiveInfoDetectionIsIncluded

**Total Schema**: 304 columns utilizing 61% of Azure table capacity (500 column limit), leaving 39% headroom for future Microsoft API additions.

**Note**: DLP events from the DLP connector can be identified by filtering on `RecordType in (11, 13, 33, 63, 99, 100, 107, 187)`.

## Architecture

The solution creates a complete dual-connector data ingestion pipeline with **shared infrastructure**:

### Deployed Resources:
- **Data Collection Endpoint (DCE)**: `dce-m365-auditgeneral` - Shared network endpoint for secure data ingestion
- **Data Collection Rule (DCR)**: `dcr-m365-auditgeneral` - Shared data stream definition with transformation logic and filtering
- **Custom Table**: `M365AuditGeneral_CL` - Shared Log Analytics table with 304 structured columns covering 30 workload schemas
- **Audit.General Data Connector**: RestApiPoller for Audit.General content type
- **Audit.DLP Data Connector**: RestApiPoller for DLP.All content type

Both connectors share the same DCE, DCR, and table - differing only in the API endpoint they poll (contentType=Audit.General vs contentType=DLP.All).

### Data Flow:

1. **Authentication**: 
   - Connector uses OAuth 2.0 client credentials flow
   - Authenticates with your Entra ID app registration
   - Token endpoint uses subscription's tenant ID automatically

2. **First API Call** (Content Blob Metadata):
   - Polls: `https://manage.office.com/api/v1.0/{tenantId}/activity/feed/subscriptions/content?contentType=Audit.General`
   - Returns: Array of content blobs with `contentUri`, `contentId`, `contentType`, `contentCreated`
   - Frequency: Every 5 minutes

3. **Nested URL Extraction**:
   - KQL parser extracts `contentUri` from each blob metadata
   - Generates dynamic API endpoints for second-step calls

4. **Second API Calls** (Actual Audit Events):
   - Fetches from each `contentUri` (e.g., `https://manage.office.com/api/v1.0/{tenantId}/activity/feed/audit/...`)
   - Returns: Array of actual audit event records with full details

5. **Data Transformation**:
   - DCR applies KQL transform: `source | where RecordType != 21 and RecordType != 278 and RecordType != 25 and RecordType != 71 and RecordType != 72 and RecordType != 75 and RecordType != 82 and RecordType != 83 and RecordType != 84 and RecordType != 93 and RecordType != 94 and RecordType != 95 and RecordType != 96 and RecordType != 97`
   - **Intelligent filtering**: Excludes Dynamics 365 (RecordTypes 21, 278), Teams (RecordType 25), and Microsoft Purview Information Protection (RecordTypes 71, 72, 75, 82, 83, 84, 93, 94, 95, 96, 97) events to avoid duplication with dedicated connectors
   - **Automatic type mapping**: DCR engine handles type conversions based on schema declarations
   - Projects 304 structured columns across 30 workload schemas

6. **Ingestion**:
   - Transformed data sent to custom table via DCE
   - Data appears in `M365AuditGeneral_CL` within minutes

### Why Two-Step Fetching?

The Office 365 Management Activity API uses a two-step pattern:
- **Step 1**: Returns content blob metadata (lightweight, pagination-friendly)
- **Step 2**: Returns actual audit events (can be large, multiple blobs per time window)

This design allows efficient polling and handles high-volume audit data across multiple content blobs.

## References

- [Office 365 Management Activity API Reference](https://docs.microsoft.com/office/office-365-management-api/office-365-management-activity-api-reference)
- [Office 365 Management Activity API Schema](https://docs.microsoft.com/office/office-365-management-api/office-365-management-activity-api-schema)
- [Microsoft Sentinel Codeless Connector Platform (CCP)](https://learn.microsoft.com/azure/sentinel/create-codeless-connector)
- [Azure Monitor Data Collection Rules](https://learn.microsoft.com/azure/azure-monitor/essentials/data-collection-rule-overview)
- [Microsoft Entra ID App Registrations](https://learn.microsoft.com/entra/identity-platform/quickstart-register-app)

## License

This project is licensed under the MIT License.

## Contributing

Contributions are welcome! Please submit pull requests or open issues for bugs and feature requests.

## Changelog

### Version 1.0.0
- **Dual-connector solution**: Audit.General + Audit.DLP connectors sharing infrastructure
- **Comprehensive 304-column schema** covering 30 specialty workload types (29 general + 1 DLP)
- **Shared infrastructure**: Both connectors use same DCE, DCR, and table - efficient resource utilization
- **Intelligent filtering**: Excludes Dynamics 365 (RecordTypes 21, 278), Teams (RecordType 25), and Microsoft Purview Information Protection events (71, 72, 75, 82, 83, 84, 93, 94, 95, 96, 97) to avoid duplication with dedicated connectors
- **Complete CCF (codeless connector framework) implementation**: DCE, DCR with KQL transformation, custom table, connector definition, OAuth 2.0 authentication
- **Nested API calls**: Two-step content blob fetching pattern for efficient data retrieval
- **Simplified deployment**: Single ARM template deploys both connectors with only 2 required parameters (workspace, workspace-location)
- **Production-ready architecture**: Dependency management, proper column naming, type safety, 61% table capacity utilization

---

## Setup

### 1. Entra ID Application Registration

You need to register a Microsoft Entra ID (formerly Azure AD) application with the appropriate permissions. **You can use the same app for both connectors**, or create separate apps.

#### Step-by-step:

1. Navigate to [Azure Portal](https://portal.azure.com) > **Microsoft Entra ID** > **App registrations**
2. Click **New registration**
3. Provide a name, e.g., `Sentinel-M365AuditGeneral`
4. **Supported account types**: Select "Accounts in this organizational directory only"
5. Click **Register**
6. Note the following values (you'll need these later):
   - **Application (client) ID**
   - **Directory (tenant) ID**

#### Create Client Secret:

7. Go to **Certificates & secrets** > **New client secret**
8. Add a description (e.g., "Sentinel Connector")
9. Set expiration period
10. Click **Add**
11. ⚠️ **Copy the secret Value immediately** - it won't be shown again

#### Configure API Permissions:

12. Go to **API permissions** > **Add a permission**
13. Select **Office 365 Management APIs** (not Microsoft Graph!)
14. Choose **Application permissions**
15. Select the required permissions:
    - **ActivityFeed.Read** (required for Audit.General connector)
    - **ActivityFeed.ReadDlp** (required for Audit.DLP connector)
16. Click **Add permissions**
17. Click **Grant admin consent for [your organization]**
18. Verify both permissions show status as **Granted**

⚠️ **Note**: If using the same app for both connectors, add both permissions. ActivityFeed.ReadDlp does NOT include ActivityFeed.Read - they are separate permissions.

### 2. Enable Office 365 Audit Logging

Ensure that audit logging is enabled in your Microsoft 365 tenant:

1. Go to [Microsoft Purview compliance portal](https://compliance.microsoft.com)
2. Navigate to **Audit**
3. Ensure audit logging is turned on
4. Note: It may take up to 60 minutes for audit logging to become fully active after enabling

### 3. Subscribe to Content Types

⚠️ **Critical Step**: Before each connector can retrieve data, you must subscribe to its content type using the Office 365 Management API.

#### Subscribe to Audit.General (for Audit.General connector)

Run this PowerShell script to create the Audit.General subscription:

```powershell
# Replace with your values
$tenantId = 'YOUR_TENANT_ID'
$clientId = 'YOUR_CLIENT_ID'
$clientSecret = 'YOUR_CLIENT_SECRET'
$publisherId = $tenantId  # Publisher identifier is your tenant ID

# Get OAuth token
$body = @{
    grant_type    = 'client_credentials'
    client_id     = $clientId
    client_secret = $clientSecret
    resource      = 'https://manage.office.com'
}
$tokenResponse = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$tenantId/oauth2/token" -Body $body
$token = $tokenResponse.access_token

# Start subscription
$headers = @{Authorization = "Bearer $token"}
$subscribeUri = "https://manage.office.com/api/v1.0/$tenantId/activity/feed/subscriptions/start?contentType=Audit.General&PublisherIdentifier=$publisherId"
Invoke-RestMethod -Method Post -Uri $subscribeUri -Headers $headers
```

#### Subscribe to DLP.All (for DLP connector)

Run this PowerShell script to create the DLP.All subscription:

```powershell
# Replace with your values
$tenantId = 'YOUR_TENANT_ID'
$clientId = 'YOUR_CLIENT_ID'
$clientSecret = 'YOUR_CLIENT_SECRET'
$publisherId = $tenantId  # Publisher identifier is your tenant ID

# Get OAuth token
$body = @{
    grant_type    = 'client_credentials'
    client_id     = $clientId
    client_secret = $clientSecret
    resource      = 'https://manage.office.com'
}
$tokenResponse = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$tenantId/oauth2/token" -Body $body
$token = $tokenResponse.access_token

# Start DLP subscription
$headers = @{Authorization = "Bearer $token"}
$subscribeUri = "https://manage.office.com/api/v1.0/$tenantId/activity/feed/subscriptions/start?contentType=DLP.All&PublisherIdentifier=$publisherId"
Invoke-RestMethod -Method Post -Uri $subscribeUri -Headers $headers
```

**Note**: You can use the **same Publisher ID** (tenant ID) for both subscriptions.

### 4. Microsoft Sentinel Workspace

- An active Microsoft Sentinel workspace
- Contributor permissions on the workspace and resource group

## Deployment

### Option 1: Deploy via Azure Portal

1. Click the **Deploy to Azure** button below:

   [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmarkolauren%2Fsentinel%2Frefs%2Fheads%2Fmain%2FM365AuditGeneralAndDLPSolution%2FM365AuditGeneralAndDLPSolution.json)

2. Fill in the required parameters:
   - **Workspace**: Your Sentinel workspace name
   - **Workspace Location**: Select your workspace region from the dropdown

3. Click **Review + create** then **Create**

### Option 2: Deploy via PowerShell

```powershell
# Set your parameters
$resourceGroupName = "your-resource-group"
$workspaceName = "your-sentinel-workspace"
$templateFile = ".\M365AuditGeneralAndDLPSolution.json"

# Deploy the template
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile $templateFile `
    -workspace $workspaceName `
    -workspace-location "eastus2" `
    -Verbose
```

### Option 3: Deploy via Azure CLI

```bash
# Set your parameters
RESOURCE_GROUP="your-resource-group"
WORKSPACE_NAME="your-sentinel-workspace"
TEMPLATE_FILE="./M365AuditGeneralAndDLPSolution.json"

# Deploy the template
az deployment group create \
    --resource-group $RESOURCE_GROUP \
    --template-file $TEMPLATE_FILE \
    --parameters workspace=$WORKSPACE_NAME workspace-location=eastus2
```

## Configuration

After deployment, you need to connect **connector(s)** (they can share the same credentials):

### Connect Audit.General Connector

1. Navigate to your Microsoft Sentinel workspace
2. Go to **Data connectors**
3. Search for "Microsoft 365 Audit.General"
4. Click on the connector and then **Open connector page**
5. In the configuration section, provide:
   - **Application (Client) ID**: Your Entra ID application (client) ID
   - **Client Secret Value**: Your Entra ID application client secret
6. Click **Connect**

### Connect Audit.DLP Connector

1. In the same **Data connectors** page, search for "Microsoft 365 Audit.DLP"
2. Click on the connector and then **Open connector page**
3. Provide the **same or different** credentials:
   - **Application (Client) ID**: Your Entra ID application (client) ID (can be same as Audit.General)
   - **Client Secret Value**: Your Entra ID application client secret
4. Click **Connect**

Both connectors will automatically use your Azure subscription's tenant ID for authentication and API calls - no need to manually enter it!

⚠️ **Note**: Initial data may take 30-60 minutes to appear after connecting each connector.

## Troubleshooting

### No data appearing in the table

1. **Verify subscription**: Run the PowerShell script again to confirm the subscription is active
2. **Check connector status**: Verify the connector shows as "Connected" in the Sentinel data connectors page
3. **Verify audit logging**: Ensure Office 365 audit logging is enabled (may take up to 60 minutes after enabling)
4. **Check permissions**: Verify the Entra ID app has **Office 365 Management APIs - ActivityFeed.Read and/or ActivityFeed.ReadDlp** permission with admin consent granted
5. **Review health logs**: Check SentinelHealth table for connector errors:
   ```kql
   SentinelHealth
   | where SentinelResourceType == "Data connector"
   | where SentinelResourceName contains "M365Audit"
   | sort by TimeGenerated desc
   ```
6. **Wait for data**: Initial data may take 30-60 minutes to appear after connecting

### Authentication errors

- Verify the Client ID and Client Secret are correct
- Ensure the client secret hasn't expired (check in Entra ID > App registrations)
- Confirm admin consent was granted for the ActivityFeed.Read permission
- Check that the app registration is in the same tenant as your Sentinel workspace

### Verify Data Collection Resources

```powershell
# List Data Collection Rules
Get-AzDataCollectionRule -ResourceGroupName "your-resource-group" | Where-Object {$_.Name -like "*m365*"}

# List Data Collection Endpoints
Get-AzDataCollectionEndpoint -ResourceGroupName "your-resource-group" | Where-Object {$_.Name -like "*m365*"}
```

### Check if subscription is active

```powershell
$tenantId = "YOUR_TENANT_ID"
$clientId = "YOUR_CLIENT_ID"
$clientSecret = "YOUR_CLIENT_SECRET"

# Get token
$body = @{
    grant_type = 'client_credentials'
    client_id = $clientId
    client_secret = $clientSecret
    resource = 'https://manage.office.com'
}
$tokenResponse = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$tenantId/oauth2/token" -Body $body
$headers = @{Authorization = "Bearer $($tokenResponse.access_token)"}

# List subscriptions
$listUri = "https://manage.office.com/api/v1.0/$tenantId/activity/feed/subscriptions/list"
Invoke-RestMethod -Method Get -Uri $listUri -Headers $headers | Format-Table
```
