# Sentinel-Defender-Graph MCP Orchestration 

## How to Choose the Right MCP

<img width="627" height="798" alt="1-decisiontree" src="https://github.com/user-attachments/assets/e382a2e4-77e1-4b3e-b77d-281727ae4151" />


### Intent Recognition

Analyze the request for:
- **Data type** (users, sign-ins, incidents, alerts, devices)
- **Action** (query, list, search, investigate)
- **Domain** (identity, security ops, endpoints, cloud apps)

### MCP Capability Mapping

**Microsoft Graph MCP**
- Azure AD/Entra ID user management
- Directory information (groups, apps, service principals)
- Organizational data (licenses, subscriptions)
- Individual entity lookups by ID
- Direct API access for specific resources

**Sentinel MCP**
- **Log Analytics Tables:** SigninLogs, AADNonInteractiveUserSignInLogs, AADManagedIdentitySignInLogs, AADServicePrincipalSignInLogs
- **Security Events:** SecurityEvent, Syslog, CommonSecurityLog, AzureActivity
- **Azure AD Logs:** AuditLogs, AADRiskyUsers, AADUserRiskEvents, AADRiskyServicePrincipals
- **Identity Protection:** IdentityInfo, IdentityLogonEvents, IdentityQueryEvents, IdentityDirectoryEvents
- **Threat Intelligence:** ThreatIntelligenceIndicator
- **Custom Tables:** Any ingested workspace data via KQL
- **Capabilities:** Historical security data aggregation, threat hunting, table schema exploration
- **Query Language:** KQL (Kusto Query Language) - optimized for large-scale log analysis

**Defender MCP**
- **Incidents & Alerts:** Security incidents with correlation, alert details, severity classification
- **Device/Endpoint Data:** DeviceInfo, DeviceLogonEvents, DeviceProcessEvents, DeviceNetworkEvents, DeviceFileEvents, DeviceRegistryEvents, DeviceImageLoadEvents
- **Identity & Authentication:** IdentityLogonEvents, IdentityQueryEvents, IdentityDirectoryEvents, AADSignInEventsBeta, AADSpnSignInEventsBeta
- **Email & Collaboration:** EmailEvents, EmailAttachmentInfo, EmailUrlInfo, EmailPostDeliveryEvents
- **Cloud Applications:** CloudAppEvents (SaaS activity: Copilot, Teams, SharePoint, OneDrive, Exchange, Azure Portal, Sentinel, Defender)
- **Threat Intelligence:** AlertInfo, AlertEvidence, files (hash, publisher, prevalence), IPs (statistics, alerts), indicators (IOCs)
- **Vulnerability Management:** Device vulnerabilities, CVE exposure, remediation activities, security recommendations
- **Investigation & Response:** Automated investigations, remediation tasks, live response actions
- **Advanced Hunting:** KQL queries across 30+ Microsoft 365 Defender tables
- **Entity Details:** Machine info (OS, risk score, exposure level), user logon history, file statistics

### Selection Hierarchy

<img width="629" height="440" alt="2-simpleorchestration" src="https://github.com/user-attachments/assets/d812d356-eac8-49d4-8c3f-02547a2f61d1" />

**Identity/User Queries:**
- Simple lookups → Graph MCP
- Activity analysis → Sentinel MCP

**Security Investigations:**
- Alert/incident details → Defender MCP
- Log correlation/hunting → Sentinel MCP
- Entity enrichment → Graph MCP

**Cloud App Activity:**
- CloudAppEvents (SaaS interactions) → Defender MCP
- Audit logs (AAD operations) → Sentinel MCP

**Endpoint Security:**
- Device processes/network/files → Defender MCP
- Device authentication logs → Sentinel MCP (if ingested)

**Email Threats:**
- Email events/attachments/URLs → Defender MCP
- Email audit logs → Sentinel MCP

**Vulnerability Assessment:**
- CVE exposure, security recommendations → Defender MCP
- Vulnerability scan results (custom) → Sentinel MCP

## Multi-MCP Orchestration for Complex Queries

<img width="624" height="1142" alt="3-complexorchestration" src="https://github.com/user-attachments/assets/d82d9170-dde0-48e1-a902-60bb5303ed26" />

### Sequential vs Parallel Execution

**Complex Question Example:**
*"Show me high-severity incidents from the last 24h involving admin users and their activity"*

<img width="630" height="535" alt="4-parallelorchestration" src="https://github.com/user-attachments/assets/d3f4f25c-9e58-4a4b-b43f-edd29943852b" />

### Orchestration Phases

**1. Decomposition**
```
Task 1: Get high-severity incidents → Defender MCP (ListIncidents API)
Task 2: Identify involved users → Parse incident data
Task 3: Verify admin status → Graph MCP (roleAssignments)
Task 4: Get user activities → Sentinel MCP (SigninLogs, AuditLogs via KQL)
Task 5: Check endpoint activity → Defender MCP (DeviceLogonEvents via Advanced Hunting)
```

**2. Dependency Analysis**
```
Defender MCP (incidents)
    ↓ [extract user IDs]
Graph MCP (verify admin status)
    ↓ [confirmed admin IDs]
Sentinel MCP (query activities)
    ↓ [results]
```

**3. Execution Patterns**

*Pattern A: Sequential with Data Flow*
```javascript
Step 1: ListIncidents (Defender)
  → Extract: ["user1@domain.com", "user2@domain.com"]
Step 2: Get user roles (Graph)
  → Filter: Admins only
Step 3: Query logs (Sentinel)
  → KQL: where UserPrincipalName in (admins)
```

*Pattern B: Parallel (Independent Queries)*
```javascript
[Graph: User profile]  ←─ Independent
[Sentinel: Sign-ins]   ←─ Independent
[Defender: Alerts]     ←─ Independent
    ↓
Combine results
```

### Optimization Strategy

<img width="628" height="711" alt="5-optimization" src="https://github.com/user-attachments/assets/74ba02fe-acf7-4bb2-9ae1-0df5593f9cf6" />

**Example:** *"Which admin users signed in from risky locations today?"*

**Efficient approach:**
1. **Sentinel MCP first** (filter at data layer)
   - Query: `SigninLogs | where RiskLevel != "none"`
   - Extract user list from results
2. **Graph MCP** to verify admin status (small filtered set)

**Why?** Filtering 100K sign-ins to 10 risky ones, then checking 10 users for admin status is faster than checking 500 admins against 100K sign-ins.

### Context Passing Between MCPs

```javascript
// Extract from first call
const incidents = await DefenderMCP.ListIncidents()
const userIds = incidents.map(i => i.impactedUsers)

// Pass to second call
const admins = await GraphMCP.FilterAdminUsers(userIds)

// Use filtered results in third call
const activities = await SentinelMCP.QueryLake({
  query: `SigninLogs | where UserId in ("${admins}")`
})
```

### Cross-MCP Correlation

**Scenario:** *"Devices with critical vulnerabilities AND failed admin sign-ins (last hour)"*

```
Parallel Phase:
├─ Defender: ListDefenderMachinesByVulnerability(CVE-XXXX) + GetDefenderMachine(vulnerabilities)
└─ Sentinel: SigninLogs | where ResultType != "0" and TimeGenerated > ago(1h)

Correlation:
├─ Extract device names from both sources
├─ Find intersection (devices in both result sets)
└─ Enrich with details from Graph MCP (user roles, device ownership)

Deep Dive:
├─ Sentinel: DeviceLogonEvents (full timeline for matched devices)
├─ Defender: DeviceProcessEvents, DeviceNetworkEvents (endpoint activity)
└─ Graph: User risk level, conditional access policies
```

**Real-World Example:** *"Suspicious file executed on multiple devices"*

```
Phase 1 - File Analysis:
└─ Defender: GetDefenderFileInfo(fileHash) → prevalence, signer, reputation

Phase 2 - Spread Assessment (Parallel):
├─ Defender: GetDefenderFileRelatedMachines(fileHash) → device list
├─ Defender: GetDefenderFileAlerts(fileHash) → triggered alerts
└─ Sentinel: DeviceFileEvents | where SHA256 == "hash" → execution timeline

Phase 3 - User Context:
├─ Defender: GetDefenderMachineLoggedOnUsers(deviceIds) → user accounts
└─ Graph: Check user roles and risk levels

Phase 4 - Network Activity:
└─ Defender: DeviceNetworkEvents | where DeviceName in (devices) → external connections
```

### Decision Framework

**Use Single MCP when:**
- All data in one domain
- Simple lookup/list operation
- No enrichment needed

**Use Multiple MCPs when:**
- Correlation across domains required
- Enrichment needed (add context)
- Complex filtering across sources
- One provides IDs, another provides details

**Call Order Priority:**
1. **Broadest filter first** (reduce dataset early)
2. **ID resolution** (get keys for next queries)
3. **Enrichment** (add details to filtered set)
4. **Deep dive** (detailed context on specific items)

### Key Principles

<img width="636" height="379" alt="6-summary" src="https://github.com/user-attachments/assets/7bcb1a19-cd5f-4868-940c-51a7316b5e73" />

✓ **Think like database joins** - start with smallest result set
✓ **Push filters to data source** (KQL, Graph filters)
✓ **Avoid** getting everything then filtering in memory
✓ **Minimize** data transfer and API calls
✓ **Maximize** information quality

**Goal:** Efficient orchestration = Right MCP + Right order + Right filters
