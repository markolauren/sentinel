$tableParams = @'
{
    "properties": {
        "schema": {
            "name": "BasicSyslog_CL",
            "columns": [

		{"name":"SourceSystem","type":"string"},
		{"name":"TimeGenerated","type":"datetime"},
		{"name":"Computer","type":"string"},
		{"name":"EventTime","type":"datetime"},
		{"name":"Facility","type":"string"},
		{"name":"HostName","type":"string"},
		{"name":"SeverityLevel","type":"string"},
		{"name":"SyslogMessage","type":"string"},
		{"name":"ProcessID","type":"int"},
		{"name":"HostIP","type":"string"},
		{"name":"ProcessName","type":"string"},
		{"name":"MG","type":"guid"},
		{"name":"CollectorHostName","type":"string"}


            ]
        }
    }
}
'@

Invoke-AzRestMethod -Path "(your sentinel path)/tables/BasicSyslog_CL?api-version=2021-12-01-preview" -Method PUT -payload $tableParams
