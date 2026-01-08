# Microsoft 365 Audit Schemas used in M365AuditGeneralAndDLPSolution / M365AuditGeneral_CL table

## Common schema

| Parameter | Type | Description |
|-----------|------|-------------|
| Id | Edm.Guid | Unique identifier of an audit record. |
| RecordType | Self.AuditLogRecordType | The type of operation indicated by the record. See the AuditLogRecordType table for details on the types of audit log records. |
| CreationTime | Edm.Date | The date and time in Coordinated Universal Time (UTC) when the audit log record was generated. |
| Operation | Edm.String | The name of the user or admin activity. For a description of the most common operations/activities, see Search the audit log. For Exchange admin activity, this property identifies the name of the cmdlet that was run. For Dlp events, this can be "DlpRuleMatch", "DlpRuleUndo" or "DlpInfo", which are described under "DLP schema" below. |
| OrganizationId | Edm.Guid | The GUID for your organization's Office 365 tenant. This value is always the same for your organization, regardless of the Office 365 service in which it occurs. |
| UserType | Self.UserType | The type of user that performed the operation. See the UserType table for details on the types of users. |
| UserKey | Edm.String | An alternative ID for the user identified in the UserId property. This property is populated with the passport unique ID (PUID) for events performed by users in SharePoint, OneDrive, and Exchange. |
| Workload | Edm.String | The Office 365 service where the activity occurred. |
| ResultStatus | Edm.String | Indicates whether the action (specified in the Operation property) was successful or not. Possible values are Succeeded, PartiallySucceeded, or Failed. For Exchange admin activity, the value is either True or False. Important: Different workloads might overwrite the value of the ResultStatus property. For example, for Microsoft Entra ID STS logon events, a value of Succeeded for ResultStatus indicates only that the HTTP operation was successful; it doesn't mean the logon was successful. To determine if the actual logon was successful or not, see the LogonError property in the Microsoft Entra ID STS Logon schema. If the logon failed, the value of this property contains the reason for the failed logon attempt. |
| ObjectId | Edm.String | For SharePoint and OneDrive activity, the full path name of the file or folder accessed by the user. For Exchange admin audit logging, the name of the object that was modified by the cmdlet. For Cloud Policy service, the object ID of the policy configuration. For TrainableClassifier activity, the id of the model created, published, updated, or deleted by the user. |
| UserId | Edm.String | The UPN (User Principal Name) of the user who performed the action (specified in the Operation property) that resulted in the record being logged; for example, my_name@my_domain_name. Note: Records for activity performed by system accounts (such as SHAREPOINT\system or NT AUTHORITY\SYSTEM) are also included. In SharePoint, another value display in the UserId property is app@sharepoint. This value indicates the "user" who performed the activity was an application that has the necessary permissions in SharePoint to perform organization-wide actions (such as search a SharePoint site or OneDrive account) on behalf of a user, admin, or service. |
| ClientIP | Edm.String | The IPv4 or IPv6 address of the device that was used when the activity was logged. For some services, the value displayed in this property might be the IP address for a trusted application (for example, Office on the web apps) calling into the service on behalf of a user and not the IP address of the device used by person who performed the activity. Also, for Microsoft Entra ID-related events, the IP address isn't logged and the value for the ClientIP property is null. |
| Scope | Self.AuditLogScope | Event created by one of the following sources: online: A service in Microsoft 365. onprem: A service in an on-premises organization. Currently, SharePoint is the only workload sending events from on-premises to Microsoft 365. |
| AppAccessContext | Collection(Self.AppAccessContext) | The application context for the user or service principal that performed the action. |

## Project schema

| Parameter | Type | Description |
|-----------|------|-------------|
| Entity | Edm.String | ProjectEntity the audit was for. |
| Action | Edm.String | ProjectAction that was taken. |
| OnBehalfOfResId | Edm.Guid | The resource Id the action was taken on behalf of. |

## eDiscovery schema

| Parameter | Type | Description |
|-----------|------|-------------|
| CaseId | Edm.Guid | The identity (GUID) of the eDiscovery case. |
| CaseName | Edm.String | The name of the eDiscovery case. |
| Object1Id | Edm.String | The ID of the object (for example, a search, hold, or review set) that was created, accessed, or changed. |
| Object1Name | Edm.String | The name of the object (for example, a search, hold or review set) that was created, accessed, or changed. |
| Object1Type | Edm.String | The type of the eDiscovery object that the user created, deleted, or modified. |
| Object2Id | Edm.String | The ID of the object (for example, a search, hold, or review set) that was created, accessed, or changed. |
| Object2Name | Edm.String | The name of the object (for example, a search, hold or review set) that was created, accessed, or changed. |
| Object2Type | Edm.String | The type of the eDiscovery object that the user created, deleted, or modified. |
| StartTime | Edm.Date | The date and time in Coordinated Universal Time (UTC) when the eDiscovery activity was started. |
| EndTime | Edm.Date | The date and time in Coordinated Universal Time (UTC) when the eDiscovery activity was ended. |
| UserCancelled | Edm.Boolean | Whether the specific activity was cancelled by the user. |
| ItemIds | Collection(Edm.String) | Item IDs associated with the activity. |
| ItemNames | Collection(Edm.String) | Item names associated with the activity. |
| DataSources | Collection(Edm.String) | A list of source IDs, source names and locations associated to the activity. |
| QueryId | Edm.String | The ID of the query associated with the activity. |
| QueryText | Edm.String | The query text associated with the activity, such as a search statistic process or add to review process. |
| QueryFiles | Collection(Edm.String) | Input file names used to generate the query. This is specific to the search by file gesture. |
| Settings | Collection(Common.NameValuePair) | Settings applied to the eDiscovery activity. |
| ExtendedProperties | Collection(Common.NameValuePair) | Additional properties related to the eDiscovery activity. |
| ExportName | Edm.String | Name of the eDiscovery export. |
| JobId | Edm.String | The GUID of the eDiscovery process. |
| RecordNumber | Edm.String | Used when an audit record is divided into multiple parts due to size. It indicates the sequence of each part within the total splits. |

## Security and Compliance Center schema

| Parameter | Type | Description |
|-----------|------|-------------|
| StartTime | Edm.Date | The date and time when the cmdlet was run. |
| ClientRequestId | Edm.String | A GUID that can be used to correlate this cmdlet with portal operations. This information is used only by Microsoft support. |
| CmdletVersion | Edm.String | The build version of the cmdlet when it was run. |
| EffectiveOrganization | Edm.String | The GUID for the organization impacted by the cmdlet. (Deprecated: This parameter will eventually stop appearing.) |
| UserServicePlan | Edm.String | The service plan assigned to the user who ran the cmdlet. |
| ClientApplication | Edm.String | If the cmdlet was run by an application, as opposed to remote PowerShell, this field contains the application name. |
| Parameters | Edm.String | The name and value for parameters that were used with the cmdlet that do not include personal data. |
| NonPiiParameters | Edm.String | The name and value for parameters that were used with the cmdlet that include personal data. (Deprecated: This field will eventually stop appearing and its content will be merged with the Parameters field.) |

## Security and Compliance Alerts schema

| Parameter | Type | Description |
|-----------|------|-------------|
| AlertId | Edm.Guid | The Guid of the alert. |
| AlertType | Self.String | Type of the alert. Alert types include: System, Custom |
| Name | Edm.String | Name of the alert. |
| PolicyId | Edm.Guid | The Guid of the policy that triggered the alert. |
| Status | Edm.String | Status of the alert. Statuses include: Active, Investigating, Resolved, Dismissed |
| Severity | Edm.String | Severity of the alert. Severity levels include: Low, Medium, High |
| Category | Edm.String | Category of the alert. Categories include: AccessGovernance, DataGovernance, DataLossPrevention, InsiderRiskManagement, MailFlow, ThreatManagement, Other |
| Source | Edm.String | Source of the alert. Sources include: Office 365 Security & Compliance, Cloud App Security |
| Comments | Edm.String | Comments left by the users who have viewed the alert. By default, it's "New alert". |
| Data | Edm.String | The detailed data blob of the alert or alert entity. |
| AlertEntityId | Edm.String | The identifier for the alert entity. This parameter is only applicable to AlertEntityGenerated events. |
| EntityType | Edm.String | Type of the alert or alert entity. Entity types include: User, Recipients, Sender, MalwareFamily |

## Viva Engage schema

| Parameter | Type | Description |
|-----------|------|-------------|
| ActorUserId | Edm.String | Email of user that performed the operation. |
| ActorYammerUserId | Edm.Int64 | ID of user that performed the operation. |
| DataExportType | Edm.String | Returns "data" if data export includes messages, notes, files, topics, users and groups; returns "user" if data export includes users only. |
| FileId | Edm.Int64 | ID of the file in the operation. |
| FileName | Edm.String | Name of the file in the operation. Appears blank if not relevant to the operation. |
| GroupName | Edm.String | Name of the group in the operation. Appears blank if not relevant to the operation. |
| IsSoftDelete | Edm.Boolean | Returns "true" if the network's data retention policy is set to Soft Delete; returns "false" if the network's data retention policy is set to Hard Delete. |
| MeetingId | Edm.String | The ID of the event/teams meeting in the operation. |
| MessageId | Edm.Int64 | ID of the message in the operation. |
| ModifiedProperties | Collection(ModifiedProperty) | Includes the name of the property that was modified, the new value of the modified object and the previous value of the modified object. |
| YammerNetworkId | Edm.Int64 | Network ID of the user that performed the operation. |
| TargetObjectId | Edm.String | Entra Id of the target user in the operation. |
| TargetUserId | Edm.String | Email of target user in the operation. Appears blank if not relevant to the operation. |
| TargetYammerUserId | Edm.Int64 | ID of target user in the operation. |
| ThreadId | Edm.Int64 | ID of the Message thread in the operation. |
| VersionId | Edm.Int64 | Version ID of the file in the operation. |

## Microsoft Defender for Office 365 and Threat Investigation and Response schema

| Parameter | Type | Description |
|-----------|------|-------------|
| AttachmentData | Collection(Self.AttachmentData) | Data about attachments in the email message that triggered the event. |
| DetectionType | Edm.String | The type of detection. For example: Inline, Detected at delivery, Delayed: Detected after delivery, ZAP: Removed after delivery by zero-hour auto purge (ZAP). Events with ZAP detection type are typically preceded by a message with a Delayed detection type. |
| DetectionMethod | Edm.String | The detection method or technology used by Defender for Office 365. |
| InternetMessageId | Edm.String | The Internet Message Id. |
| NetworkMessageId | Edm.String | The Exchange Online Network Message Id. |
| P1Sender | Edm.String | The MAIL FROM address used in SMTP transmission of the email message between email servers (also known as the 5321.MailFrom address, P1 sender, or envelope sender). |
| P2Sender | Edm.String | The From address (also known as the 5322.From address or P2 sender) that's shown in email clients. |
| Policy | Self.Policy | The type of threat policy (for example, Anti-spam or Anti-phish) and related action type (for example, High Confidence Spam, Spam, or Phish) relevant to the email message. |
| Policy | Self.PolicyAction | The action configured in the threat policy (for example, Move to Junk Mail folder or Quarantine) relevant to the email message. |
| Recipients | Collection(Edm.String) | An array of recipients of the email message. |
| SenderIp | Edm.String | The IPv4 or IPv6 address that submitted the message. |
| Subject | Edm.String | The subject line of the message. |
| Verdict | Edm.String | The message verdict. |
| MessageTime | Edm.Date | Date and time in Coordinated Universal Time (UTC) the email message was received or sent. |
| EventDeepLink | Edm.String | Deep-link to the email event in Threat Explorer or Real-time detections. |
| Delivery Action | Edm.String | The original delivery action on the email message. |
| Original Delivery location | Edm.String | The original delivery location of the email message. |
| Latest Delivery location | Edm.String | The latest delivery location of the email message at the time of the event. |
| Directionality | Edm.String | Identifies whether an email message was inbound, outbound, or an intra-org message. |
| ThreatsAndDetectionTech | Edm.String | The threats and the corresponding detection technologies. This field exposes all the threats on an email message, including the latest addition on spam verdict. For example, ["Phish: [Spoof DMARC]","Spam: [URL malicious reputation]"]. The different detection threat and detection technologies are described in Detection technologies. |
| AdditionalActionsAndResults | Collection(Edm.String) | The additional actions that were taken on the email, such as ZAP or Manual Remediation. Also includes the corresponding results. |
| Connectors | Edm.String | The names and GUIDs of the connectors associated with the email. |
| AuthDetails | Collection(Self.AuthDetails) | The authentication checks that are done for the email. Also includes the values for SPF, DKIM, DMARC, and CompAuth. |
| SystemOverrides | Collection(Self.SystemOverrides) | Overrides that are applicable to the email. These can be system or user overrides. |
| Phish Confidence Level | Edm.String | Indicates the confidence level associated with Phish verdict. It can be Normal or High. |

## Attack Sim schema

| Parameter | Type | Description |
|-----------|------|-------------|
| Batch ID | Edm.String | A unique identifier for a group of records that are processed together. |
| Campaign ID | Edm.String | A unique identifier for the attack simulation training campaign. |
| UserDisplayName | Edm.String | The display name of the user involved in the attack simulation training campaign. |
| AttackTechnique | Edm.String | The attack technique used in the simulation. |
| CampaignType | Edm.String | The type of attack simulation campaign. The different types are simulation campaign, training campaign, simulation automation. |
| TimeData | Edm.Date | Campaign launch time. |
| EndTimeData | Edm.Date | Campaign end time. |
| AttackSimEvent | Self.AttackSimEventType | Type of event (user activity or message delivery state). |
| ExtendedProperties | Collection(Common.NameValuePair) | Additional properties associated with the audit record. |

## Attack Sim Admin schema

| Parameter | Type | Description |
|-----------|------|-------------|
| Batch ID | Edm.String | A unique identifier for a group of records that are processed together. |
| Campaign ID | Edm.String | A unique identifier for an attack simulation training campaign. |
| AttackTechnique | Edm.String | The attack technique used in a simulation. |
| CampaignType | Edm.String | The type of attack simulation campaign. The different types are simulation campaign, training campaign, simulation automation. |
| TimeData | Edm.Date | Campaign launch time. |
| EndTimeData | Edm.Date | Campaign end time. |
| AttackSimAdminEvent | Self.AttackSimAdminEventType | The type of attack sim admin event. |
| ExtendedProperties | Collection(Common.NameValuePair) | Additional properties associated with the audit record. |

## User Training schema

| Parameter | Type | Description |
|-----------|------|-------------|
| Batch ID | Edm.String | A unique identifier for a group of records that are processed together. |
| Campaign ID | Edm.String | A unique identifier for an attack simulation training campaign. |
| Course ID | Edm.String | A unique identifier for a training course. |
| UserDisplayName | Edm.String | The display name of the user involved in the attack simulation. |
| CampaignType | Edm.String | The type of attack simulation campaign. The different types are simulation campaign, training campaign, simulation automation. |
| TimeData | Edm.Date | Campaign launch time. |
| EndTimeData | Edm.Date | Campaign end time. |
| UserTrainingEvent | Self.UserTrainingEventType | The type of user training event. |
| ExtendedProperties | Collection(Common.NameValuePair) | Additional properties associated with the audit record. |

## Submission schema

| Parameter | Type | Description |
|-----------|------|-------------|
| AdminSubmissionRegistered | Edm.String | Admin submission is registered and is pending for processing. |
| AdminSubmissionDeliveryCheck | Edm.String | Admin submission system checked the email's policy. |
| AdminSubmissionSubmitting | Edm.String | Admin submission system is submitting the email. |
| AdminSubmissionSubmitted | Edm.String | Admin submission system submitted the email. |
| AdminSubmissionTriage | Edm.String | Admin submission triaged by grader. |
| AdminSubmissionTimeout | Edm.String | Admin submission timed out with no result. |
| UserSubmission | Edm.String | Submission was first reported by an end user. |
| UserSubmissionTriage | Edm.String | User submission is triaged by grader. |
| CustomSubmission | Edm.String | Message reported by a user was sent to the organization's custom mailbox as set in the user reported messages settings. |
| AttackSimUserSubmission | Edm.String | The user-reported message was actually a phish simulation training message. |
| AdminSubmissionTablAllow | Edm.String | An allow entry in the Tenant Allow/Block List was created at time of submission to immediately take action on similar messages while it is being rescanned. |
| SubmissionNotification | Edm.String | Admin feedback is sent to end user. |

## Automated investigation and response events in Office 365

### Investigation

| Name | Type | Description |
|------|------|-------------|
| InvestigationId | Edm.String | Investigation ID/GUID. |
| InvestigationName | Edm.String | Name of the investigation. |
| InvestigationType | Edm.String | Type of the investigation. Can take one of the following values: User-Reported Messages, Zapped Malware, Zapped Phish, Url Verdict Change (Currently, manual investigations aren't available.) |
| LastUpdateTimeUtc | Edm.Date | UTC time of the last update for an investigation. |
| StartTimeUtc | Edm.Date | Start time for an investigation. |
| Status | Edm.String | State of investigation, Running, Pending Actions, etc. |
| DeeplinkURL | Edm.String | Deep link URL to an investigation in the Microsoft Defender portal. |
| Actions | Collection (Edm.String) | Collection of actions recommended by an investigation. |
| Data | Edm.String | Data string which contains more details about investigation entities, and information about alerts related to the investigation. Entities are available in a separate node within the data blob. |

### Actions

| Field | Type | Description |
|-------|------|-------------|
| ID | Edm.String | Action ID |
| ActionType | Edm.String | The type of the action, such as email remediation. |
| ActionStatus | Edm.String | Values include: Pending, Running, Waiting on resource, Completed, Failed |
| ApprovedBy | Edm.String | Null if auto approved; otherwise, the username/id (this is coming soon) |
| TimestampUtc | Edm.DateTime | The timestamp of the action status change. |
| ActionId | Edm.String | Unique identifier for action. |
| InvestigationId | Edm.String | Unique identifier for investigation. |
| RelatedAlertIds | Collection(Edm.String) | Alerts related to an investigation. |
| StartTimeUtc | Edm.DateTime | Timestamp of action creation. |
| EndTimeUtc | Edm.DateTime | Action final status update timestamp. |
| Resource Identifiers | Edm.String | Consists of the Azure Active Directory tenant ID. |
| Entities | Collection(Edm.String) | List of one or more affected entities by action. |
| Related Alert IDs | Edm.String | Alert related to an investigation. |

## Hygiene events schema

| Parameter | Type | Description |
|-----------|------|-------------|
| Audit | Edm.String | System information related to the hygiene event. |
| Event | Edm.String | The type of hygiene event. The values for this parameter are Listed or Delisted. |
| EventId | Edm.Int64 | The ID of the hygiene event type. |
| EventValue | Edm.String | The user who was impacted. |
| Reason | Edm.String | Details about the hygiene event. |

## Power BI schema

| Parameter | Type | Description |
|-----------|------|-------------|
| AppName | Edm.String Term="Microsoft.Office.Audit.Schema.PIIFlag" Bool="true" | The name of the app where the event occurred. |
| DashboardName | Edm.String Term="Microsoft.Office.Audit.Schema.PIIFlag" Bool="true" | The name of the dashboard where the event occurred. |
| DataClassification | Edm.String Term="Microsoft.Office.Audit.Schema.PIIFlag" Bool="true" | The data classification, if any, for the dashboard where the event occurred. |
| DatasetName | Edm.String Term="Microsoft.Office.Audit.Schema.PIIFlag" Bool="true" | The name of the dataset where the event occurred. |
| MembershipInformation | Collection(MembershipInformationType) Term="Microsoft.Office.Audit.Schema.PIIFlag" Bool="true" | Membership information about the group. |
| OrgAppPermission | Edm.String Term="Microsoft.Office.Audit.Schema.PIIFlag" Bool="true" | Permissions list for an organizational app (entire organization, specific users, or specific groups). |
| ReportName | Edm.String Term="Microsoft.Office.Audit.Schema.PIIFlag" Bool="true" | The name of the report where the event occurred. |
| SharingInformation | Collection(SharingInformationType) Term="Microsoft.Office.Audit.Schema.PIIFlag" Bool="true" | Information about the person to whom a sharing invitation is sent. |
| SwitchState | Edm.String Term="Microsoft.Office.Audit.Schema.PIIFlag" Bool="true" | Information about the state of various tenant level switches. |
| WorkSpaceName | Edm.String Term="Microsoft.Office.Audit.Schema.PIIFlag" Bool="true" | The name of the workspace where the event occurred. |

## Viva Insights schema

| Parameter | Type | Description |
|-----------|------|-------------|
| WpaUserRole | Edm.String | The Viva Insights role of the user who performed the action. |
| ModifiedProperties | Collection (Common.ModifiedProperty) | This property includes the name of the property that was modified, the new value of the modified property, and the previous value of the modified property. |
| OperationDetails | Collection (Common.NameValuePair) | A list of extended properties for the setting that was changed. Each property has a Name and Value. |

## Quarantine schema

| Parameter | Type | Description |
|-----------|------|-------------|
| RequestType | Self.RequestType | The type of quarantine request performed by a user. |
| RequestSource | Self.RequestSource | Quarantine request come from the Microsoft Defender portal, a cmdlet, or a URLlink. |
| NetworkMessageId | Edm.String | The network message id of quarantined email message. |
| ReleaseTo | Edm.String | The recipient of the email message. |

## Microsoft Forms schema

| Parameter | Type | Description |
|-----------|------|-------------|
| FormsUserTypes | Collection(Self.FormsUserTypes) | The role of the user who performed the action. The values for this parameter are Admin, Owner, Responder, or Coauthor. |
| SourceApp | Edm.String | Indicates if the action is from Forms website or from another App. |
| FormName | Edm.String | The name of the current form. |
| FormId | Edm.String | The Id of the target form. |
| FormTypes | Collection(Self.FormTypes) | Indicates whether this is a Form, Quiz, or Survey. |
| ActivityParameters | Edm.String | JSON string containing activity parameters. For more information, see Microsoft Forms activities. |

## MIP label schema

| Parameter | Type | Description |
|-----------|------|-------------|
| Sender | Edm.String | The email address in the From field of the email message. |
| Receivers | Collection(Edm.String) | All email addresses in the To, CC, and Bcc fields of the email message. |
| ItemName | Edm.String | The string in the Subject field of the email message. |
| LabelId | Edm.Guid | The GUID of the sensitivity label applied to the email message. |
| LabelName | Edm.String | The name of the sensitivity label applied to the email message. |
| LabelAction | Edm.String | The actions specified by the sensitivity label that were applied to the email message before the message entered the mail transport pipeline. |
| LabelAppliedDateTime | Edm.Date | The date the sensitivity label was applied to the email message. |
| ApplicationMode | Edm.String | Specifies how the sensitivity label was applied to the email message. The Privileged value indicates the label was manually applied by a user. The Standard value indicates the label was auto-applied by a client-side or service-side labeling process. |

## Encrypted message portal events schema

| Parameter | Type | Description |
|-----------|------|-------------|
| MessageId | Edm.String | The Id of the message. |
| Recipient | Edm.String | Recipient email address. |
| Sender | Edm.String | Email address of sender. |
| AuthenticationMethod | Self.AuthenticationMethod | Authentication method when accessing the message, i.e. OTP, Yahoo, Gmail, Microsoft. |
| AuthenticationStatus | Self.AuthenticationStatus | 0: Success, 1: Failure. |
| OperationStatus | Self.OperationStatus | 0: Success, 1: Failure. |
| AttachmentName | Edm.String | Name of the attachment. |
| OperationProperties | Collection(Common.NameValuePair) | Extra properties, i.e. number of OTP passcode sent, email subject, etc. |

## Reports schema

| Parameter | Type | Description |
|-----------|------|-------------|
| ModifiedProperties | Collection (Common.ModifiedProperty) | This property includes the name of the property that was modified, the new value of the modified property, and the previous value of the modified property. |

## Compliance connector schema

| Parameter | Type | Description |
|-----------|------|-------------|
| JobId | Edm.String | This is a unique identifier of the data connector. |
| TaskId | Edm.String | Unique identifier of the periodic data connector instance. Data connectors import data in periodic intervals. |
| JobType | Edm.String | The name of the data connector. |
| ItemId | Edm.String | Unique identifier of the item (for example, an email message) being imported. |
| ItemSize | Edm.Int64 | The size of the item being imported. |
| SourceUserId | Edm.String | The unique identifier of the user from the third-party data source. For example, for a Slack data connector, this property specifies the user Id in Slack workspace. |
| FailureType | Self.FailureType | Indicates the type of data import failure. For example, the value incorrectusermapping indicates the item wasn't imported because no user mapping between the third-party data source and Microsoft 365 could be found. |
| ResultMessage | Edm.String | Indicates the type of failure, such as Duplicate message. |
| IsRetry | Edm.Boolean | Indicates whether the data connector retried to import the item. |
| Attachments | Collection.Attachment | A list of attachments received from the third-party data source. |

## SystemSync schema

### DataLakeExportOperationAuditRecord

| Parameter | Type | Description |
|-----------|------|-------------|
| DataStoreType | DataStoreType | Indicates which data store the data was downloaded from. Refer DataStoreType for all possible values. |
| UserAction | DataLakeUserAction | Indicates what action user had performed on the data store. Refer DataLakeUserAction for all possible values. |
| ExportTriggeredAt | Edm.DateTimeOffset | Indicates when the data export was triggered. |
| NameOfDownloadedZipFile | Edm.String | The name of the compressed file the admin had downloaded from the Data Lake. |

### DataShareOperationAuditRecord

| Parameter | Type | Description |
|-----------|------|-------------|
| Invitation | DataShareInvitationType | Details of the invite sent to the recipient of the Data Share. |

## Viva Glint schema

| Parameter | Type | Description |
|-----------|------|-------------|
| ClientUUID | Edm.String | The Client UUID of the Viva Glint instance. |
| ImportType | Edm.String | The data import source type. |
| DataDSRControl | Edm.String | This in-platform control determines whether survey data is deleted when a user is removed from the Viva Glint platform. |
| DiscardEmployeeIds | Edm.String | This in-platform control specifies whether the Employee IDs of previously deleted employees are disregarded or retained in the Viva Glint platform. |
| JobName | Edm.String | The name of a Glint data app job that was run. |
| ExtendedCompletionDate | Edm.Date | The new date to which a closed survey cycle has been extended. |
| FeedBackComponentName | Edm.String | The name of a specific component within the 360 feedback program. |

## Viva Goals schema

| Parameter | Type | Description |
|-----------|------|-------------|
| Detail | Edm.String | A description of the event or the activity that occurred in Viva Goals. |
| Username | Edm.String Term="Microsoft.Office.Audit.Schema.PIIFlag" Bool="true" | The name of the user who triggered the event. |
| UserRole | Edm.String | The role of the user who triggered this event in Viva Goals. This value mentions if the user is an organization admin or an owner. |
| OrganizationName | Edm.String Term="Microsoft.Office.Audit.Schema.PIIFlag" Bool="true" | The name of the organization in Viva Goals where the event was triggered. |
| OrganizationOwner | Edm.String Term="Microsoft.Office.Audit.Schema.PIIFlag" Bool="true" | The owner of the organization in Viva Goals where the event occurred. |
| OrganizationAdmins | Collection(Edm.String) Term="Microsoft.Office.Audit.Schema.PIIFlag" Bool="true" | The admin(s) of the organization in Viva Goals where the event occurred. There can be one or more admins in the organization. |
| UserAgent | Edm.String Term="Microsoft.Office.Audit.Schema.PIIFlag" Bool="true" | The user agent (browser details) of the user who triggered the event. UserAgent might not be present in case of a system generated event. |
| ModifiedFields | Collection(Common.NameValuePair) | A list of attributes that were modified along with its new and old values output as a JSON. |
| ItemDetails | Collection(Common.NameValuePair) | Additional properties about the object that was modified. |

## Backup Policy schema

| Parameter | Type | Description |
|-----------|------|-------------|
| PolicyID | Edm.String | The ID of the policy. |
| EditMethodology | Edm.String | How the policy was created / edited. |
| CountOfArtifactsBeingAdded | Edm.Int32 | Number of artifacts being added. |
| CountOfArtifactsBeingRemoved | Edm.Int32 | Number of artifacts being removed. |
| ServiceType | Edm.String | Whether it is a SharePoint, Exchange, or OneDriveForBusiness policy. |

## Restore Task schema

| Parameter | Type | Description |
|-----------|------|-------------|
| TaskID | Edm.String | The ID of the Restore Task. |
| CreationMethodology | Edm.String | How the Restore Task was created / edited. |
| CountOfArtifactsBeingAdded | Edm.Int32 | Number of artifacts being added. |
| CountOfArtifactsBeingRemoved | Edm.Int32 | Number of artifacts being removed. |
| ServiceType | Edm.String | Whether it is a SharePoint, Exchange, or OneDriveForBusiness policy. |

## Restore Item schema

| Parameter | Type | Description |
|-----------|------|-------------|
| RestoreTime | Edm.DateTime | Time which the item is being restored to. |
| RestoreLocationType | Edm.String | Location type that the item is being restored to. |
| RestoreLocation | Edm.String | Location that the item is being restored to. |
| TaskID | Edm.String | The ID of the Restore task. |
| BackupItemID | Edm.String | ID of the Backup Item being restored. |
| ProtectionUnitID | Edm.String | Protection Unit ID of the item being restored. |
| SuccessStatus | Edm.String | Whether the restore operation was successful. |
| BackupItemType | Edm.String | Whether the Backup Item is a Site / Account / Mailbox. |
| ServiceType | Edm.String | Whether it is a SharePoint, Exchange, or OneDriveForBusiness policy. |

## Backup Item schema

| Parameter | Type | Description |
|-----------|------|-------------|
| PolicyID | Edm.String | Policy ID of the Policy the item is getting added to. |
| ItemID | Edm.String | ID of the Backup Item. |
| ProtectionUnitID | Edm.String | Protection Unit ID of the item being backed up. |
| ResultStatus | Edm.String | Whether the restore operation was successful. |
| BackupItemType | Edm.String | Whether the Backup Item is a Site / Account / Mailbox. |
| EditMethodology | Edm.String | How the backup item is to be added. |
| ServiceType | Edm.String | Whether it is a SharePoint, Exchange, or OneDriveForBusiness policy. |

## Microsoft Edge WebContentFiltering schema

| Parameter | Type | Description |
|-----------|------|-------------|
| URLPath | Edm.String | The URL that was browsed. |
| DomainURL | Edm.String | The domain URL that was browsed. |
| Category | Edm.String | Category of browsed URL. |

## Microsoft 365 Copilot scheduled prompt schema

| Parameter | Type | Description |
|-----------|------|-------------|
| ScenarioType | Edm.String | The name of automation. |
| PromptText | Edm.String | The Copilot prompt that's run by the LLM. |
| AutomationId | Edm.String | A unique identifier that correlates all activities related to each run of the Copilot prompt. |
| TriggerMode | Edm.String | The schedule for when the Copilot prompt runs, shown in cron format. |

## Microsoft Places Directory schema

| Parameter | Type | Description |
|-----------|------|-------------|
| PlaceType | Edm.String | The type for the place item that is created/updated/deleted by the request. For example, "Building", "Room", "Desk", and so on. |
| Parameters | Collection(Common.NameValuePair) | The name and value for all parameters that were used with the cmdlet that is identified in the Operations property. |
| ModifiedProperties | Collection(Common.ModifiedProperty) | The property includes the name of the property that was modified, the new value of the modified property, and the previous value of the modified object. |

## Microsoft Sentinel data lake and graph schema

### SentinelNotebookOnLake

| Parameter | Type | Description |
|-----------|------|-------------|
| EventTime | Edm.Date | Timestamp when the Spark Notebook execution was submitted/started. |
| Compute | Edm.String | Compute selected. |
| DatabaseName | Edm.String | The workspace the command ran on. |
| TableName | Edm.String | Name of the table. |
| SessionDurationInSecs | Edm.String | Total duration of the session. |
| SessionStartTime | Edm.Date | Start time for the session. |
| SessionEndTime | Edm.Date | End time for the session. |
| KernalId | Edm.Guid | Jupyter KernelId, uniquely identifies the Notebook session. |
| SessionId | Edm.Guid | Correlation ID for the various code blocks executed with a Spark session. |
| Interface | Edm.String | Interface from where the notebook was run. |

### SentinelJob

| Parameter | Type | Description |
|-----------|------|-------------|
| EventTime | Edm.Date | Timestamp when the operation on job was initiated. |
| Operation | Edm.String | Job Operation name. |
| Job Type | Edm.String | Type of Job like Notebook, KQL. |
| Job ID | Edm.Guid | Unique identifier of a job. |
| Job Name | Edm.String | Name of the job. |
| Compute | Edm.String | Compute configuration of the job. |
| Schedule | Edm.String | Schedule details, if configured for the job. |
| Run ID | Edm.Guid | ID of a specific job run instance. |
| JobRunStatus | Edm.String | Status of the job execution. |
| Logs | Edm.String | Logs from the notebook run. |
| JobExecutionDurationInSecs | Edm.Int64 | Time taken for job execution. |
| JobTotalDurationInSecs | Edm.Int64 | Total Duration of the job operation including session. |
| JobStartTime | Edm.Date | Start time of the job. |
| JobEndTime | Edm.Date | End time of the job. |
| Interface | Edm.String | Interface from where the job operation was done. |
| DatabasesRead | Collection(Edm.String) | The list of workspaces read by the job. |
| DatabasesWrite | Collection(Edm.String) | The list of workspaces written to by the job |
| TablesRead | Collection(Edm.String) | The list of tables read by the job. |
| TablesWrite | Collection(Edm.String) | The list of tables written to by the job. |
| Query | Edm.String | KQL query or notebook executed in the job. |

### SentinelKQLOnLake

| Parameter | Type | Description |
|-----------|------|-------------|
| EventTime | Edm.Date | Timestamp of KQL query execution. |
| DatabaseName | Collection(Edm.String) | The workspaces the KQL query ran on. |
| ResultTableCount | Edm.Int64 | Output Table Count. |
| QueryResponse | Edm.String | Response from executing the KQL query. |
| TotalRows | Collection(Edm.Int64) | Total Rows returned from query execution. List of values if multiple queries executed at once. |
| ComponentFault | Edm.String | The entity that caused the query to fail. For example, if the query result is too large, the ComponentFault is 'Client'. If an internal error occurred, the ComponentFault is 'Server'. |
| FailureReason | Edm.String | If KQL query failed, the reason for failure. |
| ExecutionDuration | Edm.Int64 | Time taken for query execution, in milliseconds. |
| TotalCPU | Edm.Int64 | Total CPU Duration of the run. |
| MemoryPeak | Edm.Int64 | Memory Peak of the KQL query execution. |
| Interface | Edm.String | Interface from where the KQL query was executed. |
| TablesRead | Collection(Edm.String) | The list of tables read in the KQL query. |
| QueryText | Edm.String | The KQL query executed in scrubbed form. |

### SentinelLakeOnboarding

| Parameter | Type | Description |
|-----------|------|-------------|
| BillingAzureSubscriptionId | Edm.String | Azure subscription chosen for Sentinel data lake billing. |
| BillingAzureResourceGroupName | Edm.String | Azure resource group chosen for Sentinel data lake billing. |
| TenantId | Edm.String | Tenant ID associated with the lake setup or update. |
| ProvisioningStatus | Edm.String | Status of provisioning the lake. |

### SentinelLakeDataOnboarding

| Property Name | Type | Description |
|---------------|------|-------------|
| DataOnboardingAtSetup | Edm.String | Data sets ingested during Sentinel data lake onboarding. |
| Tables | Collection(Edm.String) | List of table names ingested during Sentinel data lake onboarding. |
| SubscriptionsEnabled | Collection(Edm.String) | List of subscriptions enabled for ARG ingestion. |
| DataOnboardingStatus | Edm.String | Status of operation. |

### SentinelAITool

| Parameter | Type | Description |
|-----------|------|-------------|
| EventOccurenceTime | Edm.Date | Timestamp of the operation. |
| ToolID | Edm.Guid | Identifier of the AI Tool. |
| ToolName | Edm.String | Name of the AI Tool. |
| Interface | Edm.String | Interface from where the AI Tool was run. |
| InputParameters | Edm.String | Parameters given to the tool. |
| DatabasesRead | Collection(Edm.String) | The list of databases read from in the run. |
| TablesRead | Collection(Edm.String) | The list of tables read from in the run. |
| APIsCalled | Collection(Edm.String) | APIs called by the AI Tool. |
| FailureReason | Edm.String | If the run failed, the reason for failure. |
| TotalRows | Collection(Edm.Int64) | Total Rows returned. |
| DataScanned | Edm.Int64 | Total GBs Scanned. |
| ExecutionDuration | Edm.Int64 | Time taken for query execution, in milliseconds. |
| TotalCpuHours | Edm.Int64 | Total CPU Duration of the run. |
| TotalSCUHours | Edm.Int64 | Total SCUs used in the run. |

### SentinelGraph

| Parameter | Type | Description |
|-----------|------|-------------|
| EventTime | Edm.Date | Timestamp of the operation. |
| GraphName | Edm.String | Name of the graph instance. |
| Operation | Edm.string | Action taken on graph. |
| OperationInput | Edm.string | Parameters of graph action. |
| GraphQuery Stats | Edm.string | Collection of response metadata. |
| GraphQuery Status | Edm.String | Response of the query or action on graph. |
| Interface | Edm.String | Interface from where the graph action was taken. |

## Data Center Security Base schema

| Parameter | Type | Description |
|-----------|------|-------------|
| DataCenterSecurityEventType | Self.DataCenterSecurityEventType | The type of cmdlet event in lock box. |

## Data Center Security Cmdlet schema

| Parameter | Type | Description |
|-----------|------|-------------|
| StartTime | Edm.Date | The start time of the cmdlet execution. |
| EffectiveOrganization | Edm.String | The name of the tenant that the elevation/cmdlet was targeted at. |
| ElevationTime | Edm.Date | The start time of the elevation. |
| ElevationApprover | Edm.String | The name of a Microsoft manager. |
| ElevationApprovedTime | Edm.Date | The timestamp for when the elevation was approved. |
| ElevationRequestId | Edm.Guid | A unique identifier for the elevation request. |
| ElevationRole | Edm.String | The role the elevation was requested for. |
| ElevationDuration | Edm.Int32 | The duration for which the elevation was active. |
| GenericInfo | Edm.String | Used for comments and other generic information. |

## Viva Pulse schema

| Parameter | Type | Description |
|-----------|------|-------------|
| EventName | Edm.String | A description of the event or the activity that occurred in Viva Pulse. |
| PulseId | Edm.String | Id of the pulse survey. |
| EventDetails | Collection(Common.NameValuePair) | Additional properties about the event. |

## DLP schema

| Parameter | Type | Description |
|-----------|------|-------------|
| SharePointMetaData | Self.SharePointMetadata | Describes metadata about the document in SharePoint or OneDrive that contained the sensitive information. |
| ExchangeMetaData | Self.ExchangeMetadata | Describes metadata about the email message that contained the sensitive information. |
| EndpointMetaData | Self.EndpointMetadata | Describes metadata about the document in endpoint that contained the sensitive information. |
| ExceptionInfo | Edm.String | Identifies reasons why a policy no longer applies and/or any information about false positive and/or override noted by the end user. |
| PolicyDetails | Collection(Self.PolicyDetails) | Information about 1 or more policies that triggered the DLP event. |
| SensitiveInfoDetectionIsIncluded | Boolean | Indicates whether the event contains the value of the sensitive data type and surrounding context from the source content. Accessing sensitive data requires the "Read DLP policy events including sensitive details" permission in Azure Active Directory. |
