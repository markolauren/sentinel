$tableParams = @'
{
    "properties": {
        "schema": {
            "name": "BasicGraphAPI_CL",
            "columns": [

		{"name":"TimeGenerated","type":"datetime"},
		{"name":"Location","type":"string"},
		{"name":"RequestId","type":"string"},
		{"name":"OperationId","type":"string"},
		{"name":"ClientRequestId","type":"string"},
		{"name":"ApiVersion","type":"string"},
		{"name":"RequestMethod","type":"string"},
		{"name":"ResponseStatusCode","type":"int"},
		{"name":"AadTenantId","type":"string"},
		{"name":"IPAddress","type":"string"},
		{"name":"UserAgent","type":"string"},
		{"name":"RequestUri","type":"string"},
		{"name":"DurationMs","type":"int"},
		{"name":"ResponseSizeBytes","type":"int"},
		{"name":"SignInActivityId","type":"string"},
		{"name":"Roles","type":"string"},
		{"name":"TokenIssuedAt","type":"datetime"},
		{"name":"AppId","type":"string"},
		{"name":"UserId","type":"string"},
		{"name":"ServicePrincipalId","type":"string"},
		{"name":"Scopes","type":"string"},
		{"name":"IdentityProvider","type":"string"},
		{"name":"ClientAuthMethod","type":"int"},
		{"name":"Wids","type":"string"},
		{"name":"ATContent","type":"string"},
		{"name":"SourceSystem","type":"string"}

            ]
        }
    }
}
'@

Invoke-AzRestMethod -Path "(your sentinel path)/tables/BasicGraphAPI_CL?api-version=2021-12-01-preview" -Method PUT -payload $tableParams
