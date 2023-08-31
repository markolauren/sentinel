$tableParams = @'
{
    "properties": {
        "schema": {
            "name": "Fortinet_CL",
            "columns": [
                {
                    "name": "TimeGenerated",
                    "type": "DateTime"
                }, 
                {
                    "name": "DeviceVendor",
                    "type": "String"
                },
                {
                    "name": "DeviceProduct",
                    "type": "String"
                },
                {
                    "name": "DeviceVersion",
                    "type": "String"
                },
                {
                    "name": "DeviceEventClassID",
                    "type": "String"
                },
                {
                    "name": "Activity",
                    "type": "String"
                },
                {
                    "name": "LogSeverity",
                    "type": "String"
                },
                {
                    "name": "AdditionalExtensions",
                    "type": "String"
                },
                {
                    "name": "DeviceAction",
                    "type": "String"
                },
                {
                    "name": "ApplicationProtocol",
                    "type": "String"
                },
                {
                    "name": "EventCount",
                    "type": "Int"
                },
                {
                    "name": "DeviceExternalID",
                    "type": "String"
                },
                {
                    "name": "DeviceInboundInterface",
                    "type": "String"
                },
                {
                    "name": "DeviceOutboundInterface",
                    "type": "String"
                },
                {
                    "name": "DestinationPort",
                    "type": "Int"
                },
                {
                    "name": "DestinationIP",
                    "type": "String"
                },
                {
                    "name": "ExtID",
                    "type": "String"
                },
                {
                    "name": "ReceivedBytes",
                    "type": "Long"
                },
                {
                    "name": "Message",
                    "type": "String"
                },
                {
                    "name": "SentBytes",
                    "type": "Long"
                }


            ]
        }
    }
}
'@

Invoke-AzRestMethod -Path "(my sentinel path)/tables/Fortinet_CL?api-version=2021-12-01-preview" -Method PUT -payload $tableParams