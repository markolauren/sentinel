$tableParams = @'
{
    "properties": {
        "schema": {
            "name": "BasicEvent_CL",
            "columns": [

		{"name":"SourceSystem","type":"string"},
		{"name":"TimeGenerated","type":"datetime"},
		{"name":"Source","type":"string"},
		{"name":"EventLog","type":"string"},
		{"name":"Computer","type":"string"},
		{"name":"EventLevel","type":"int"},
		{"name":"EventLevelName","type":"string"},
		{"name":"ParameterXml","type":"string"},
		{"name":"EventData","type":"string"},
		{"name":"EventID","type":"int"},
		{"name":"RenderedDescription","type":"string"},
		{"name":"AzureDeploymentID","type":"string"},
		{"name":"Role","type":"string"},
		{"name":"EventCategory","type":"int"},
		{"name":"UserName","type":"string"},
		{"name":"Message","type":"string"},
		{"name":"MG","type":"guid"},
		{"name":"ManagementGroupName","type":"string"}

            ]
        }
    }
}
'@

Invoke-AzRestMethod -Path "(your sentinel path)/tables/BasicEvent_CL?api-version=2021-12-01-preview" -Method PUT -payload $tableParams
