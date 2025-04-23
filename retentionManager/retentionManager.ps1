<#       
  	THE SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SCRIPT OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

    .SYNOPSIS
        retentionManager.ps1 (v1.0)
        PowerShell tool to configure total retention & interactive retention for Sentinel/Log Analytics tables
        

    .DESCRIPTION
        It performs the following actions:
            1. Check what tables are used in the workspace
            2. Lists the tables and their current retention config (analytics/basic/auxiliary)
            3. Update total retention and/or interactive retention config for table(s)
         
    
    .PARAMETER TenantId
        Enter Azure Tenant Id (required)  

    .NOTES
        AUTHOR: Marko Lauren
        (FORKED FROM: Configure-Long-Term-Retention.ps1 by Sreedhar Ande)
        
    .EXAMPLE
        .\retentionManager.ps1 -TenantID xxxx [-All]

	    Optional -All switch determines, whether to list all tables, or the ones being used.
#>

#region UserInputs

param(
    [parameter(Mandatory = $true, HelpMessage = "Enter your Tenant Id")]
    [string] $TenantID,

    [parameter(Mandatory = $false, HelpMessage = "Include all tables instead of only used")]
    [switch] $All

) 

#endregion UserInputs
      
#region HelperFunctions

function Write-Log {
    <#
    .DESCRIPTION 
    Write-Log is used to write information to a log file and to the console.
    
    .PARAMETER Severity
    parameter specifies the severity of the log message. Values can be: Information, Warning, or Error. 
    #>

    [CmdletBinding()]
    param(
        [parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
        [string]$LogFileName,
 
        [parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information', 'Warning', 'Error')]
        [string]$Severity = 'Information'
    )
    # Write the message out to the correct channel											  
    switch ($Severity) {
        "Information" { Write-Host $Message -ForegroundColor Green }
        "Warning" { Write-Host $Message -ForegroundColor Yellow }
        "Error" { Write-Host $Message -ForegroundColor Red }
    }

    ##Logging to file? disabling by commenting out
    <#
    try {
        [PSCustomObject]@{
            Time     = (Get-Date -f g)
            Message  = $Message
            Severity = $Severity
        } | Export-Csv -Path "$PSScriptRoot\$LogFileName" -Append -NoTypeInformation -Force
    }
    catch {
        Write-Error "An error occurred in Write-Log() method" -ErrorAction SilentlyContinue		
    } 
#>
   
}

function Get-RequiredModules {
    <#
    .DESCRIPTION 
    Get-Required is used to install and then import a specified PowerShell module.
    
    .PARAMETER Module
    parameter specifices the PowerShell module to install. 
    #>

    [CmdletBinding()]
    param (        
        [parameter(Mandatory = $true)] $Module        
    )
    
    try {
        $installedModule = Get-InstalledModule -Name $Module -ErrorAction SilentlyContinue       

        if ($null -eq $installedModule) {
            Write-Log -Message "The $Module PowerShell module was not found" -LogFileName $LogFileName -Severity Warning
            #check for Admin Privleges
            $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

            if (-not ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
                #Not an Admin, install to current user            
                Write-Log -Message "Can not install the $Module module. You are not running as Administrator" -LogFileName $LogFileName -Severity Warning
                Write-Log -Message "Installing $Module module to current user Scope" -LogFileName $LogFileName -Severity Warning
                
                Install-Module -Name $Module -Scope CurrentUser -Repository PSGallery -Force -AllowClobber
                Import-Module -Name $Module -Force
            }
            else {
                #Admin, install to all users																		   
                Write-Log -Message "Installing the $Module module to all users" -LogFileName $LogFileName -Severity Warning
                Install-Module -Name $Module -Repository PSGallery -Force -AllowClobber
                Import-Module -Name $Module -Force
            }
        }
        else {
            if ($UpdateAzModules) {
                Write-Log -Message "Checking updates for module $Module" -LogFileName $LogFileName -Severity Information
                $currentVersion = [Version](Get-InstalledModule | Where-Object { $_.Name -eq $Module }).Version
                # Get latest version from gallery
                $latestVersion = [Version](Find-Module -Name $Module).Version
                if ($currentVersion -ne $latestVersion) {
                    #check for Admin Privleges
                    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

                    if (-not ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
                        #install to current user            
                        Write-Log -Message "Can not update the $Module module. You are not running as Administrator" -LogFileName $LogFileName -Severity Warning
                        Write-Log -Message "Updating $Module from [$currentVersion] to [$latestVersion] to current user Scope" -LogFileName $LogFileName -Severity Warning
                        Update-Module -Name $Module -RequiredVersion $latestVersion -Force
                    }
                    else {
                        #Admin - Install to all users																		   
                        Write-Log -Message "Updating $Module from [$currentVersion] to [$latestVersion] to all users" -LogFileName $LogFileName -Severity Warning
                        Update-Module -Name $Module -RequiredVersion $latestVersion -Force
                    }
                }
                else {
                    # Get latest version
                    $latestVersion = [Version](Get-Module -Name $Module).Version               
                    Write-Log -Message "Importing module $Module with version $latestVersion" -LogFileName $LogFileName -Severity Information
                    Import-Module -Name $Module -RequiredVersion $latestVersion -Force
                }
            }
            else {
                # Get latest version
                $latestVersion = [Version](Get-Module -Name $Module).Version               
                Write-Log -Message "Importing module $Module with version $latestVersion" -LogFileName $LogFileName -Severity Information
                Import-Module -Name $Module -RequiredVersion $latestVersion -Force
            }
        }
        # Install-Module will obtain the module from the gallery and install it on your local machine, making it available for use.
        # Import-Module will bring the module and its functions into your current powershell session, if the module is installed.  
    }
    catch {
        Write-Log -Message "An error occurred in Get-RequiredModules() method - $($_)" -LogFileName $LogFileName -Severity Error        

        #Write-Log -Message "Error details: $($_.Exception.Message)" -LogFileName $LogFileName -Severity Error
        #Write-Log -Message "Stack trace: $($_.Exception.StackTrace)" -LogFileName $LogFileName -Severity Error

    }
}

#endregion

#region MainFunctions

function Get-LATables {
    [CmdletBinding()]
	
    $TablesArray = New-Object System.Collections.Generic.List[System.Object]

    try {       
        $WSTables = Get-AllTables

        $TablesArray = $WSTables | Sort-Object -Property TableName | Select-Object -Property TableName, RetentionInWorkspace, RetentionInArchive, TotalLogRetention, IngestionPlan  | Out-GridView -Title "Select Table (For Multi-Select use CTRL)" -PassThru

        if (-not $TablesArray) {
            ##Write-Log -Message "User canceled table selection." -LogFileName $LogFileName -Severity Warning
            exit 1  # Exit with non-zero code to indicate cancellation
        }

    }
    catch {
        Write-Log $_ -LogFileName $LogFileName -Severity Error
        Write-Log -Message "An error occurred in querying table names from $LogAnalyticsWorkspaceName" -LogFileName $LogFileName -Severity Error         
        exit
    }
	
	
    return $TablesArray	
}

function Get-AllTables {		
    $AllTables = @()	

    ### QUERY ACTIVE TABLES

    if (-not $All) {
	
        $QueryApi = "https://management.azure.com/subscriptions/$SubscriptionId/resourcegroups/$LogAnalyticsResourceGroup/providers/Microsoft.OperationalInsights/workspaces/$LogAnalyticsWorkspaceName/query" + "?api-version=2017-10-01"								
		
        # Set query to get usage
        $query = 'Usage | where TimeGenerated > ago(30d) | distinct DataType'
		
        $body = @{
            query = $query
        } | ConvertTo-Json -Depth 2
		
        try {
            # Query the workspace to get the used tables
            $response = Invoke-RestMethod -Method "POST" -Uri $QueryApi -Headers $LaAPIHeaders -Body $body
            #Write-Host ($response | ConvertTo-Json -Depth 3)

        }
        catch {

            Write-Log -Message "Error querying Usage table" -LogFileName $LogFileName -Severity Error

        }
	
        $rows = $response.tables[0].rows

    }

    ### QUERY ALL TABLES AND RETENTIONS

    $TablesApi = "https://management.azure.com/subscriptions/$SubscriptionId/resourcegroups/$LogAnalyticsResourceGroup/providers/Microsoft.OperationalInsights/workspaces/$LogAnalyticsWorkspaceName/tables" + "?api-version=2022-10-01"								

    Write-Log -Message "Retrieving tables from $LogAnalyticsWorkspaceName" -LogFileName $LogFileName -Severity Information
	    		
    try {        
        $TablesApiResult = Invoke-RestMethod -Uri $TablesApi -Method "GET" -Headers $LaAPIHeaders           			
	
    } 
    catch {                    
        Write-Log -Message "Get-AllTables $($_)" -LogFileName $LogFileName -Severity Error		                
    }
	
    If ($TablesApiResult.StatusCode -ne 200) {
        $searchPattern = '(_RST)'                
        foreach ($ta in $TablesApiResult.value) { 
            try {
                if ($ta.name.Trim() -notmatch $searchPattern) {                    
                    $AllTables += [pscustomobject]@{TableName = $ta.name.Trim();
                        IngestionPlan                         = $ta.properties.Plan.Trim();
                        TotalLogRetention                     = $ta.properties.totalRetentionInDays;
                        RetentionInArchive                    = $ta.properties.archiveRetentionInDays;
                        RetentionInWorkspace                  = $ta.properties.retentionInDays
                    }  
                }
            }
            catch {
                Write-Log -Message "Error adding $ta to collection" -LogFileName $LogFileName -Severity Error
            }
	    	
        }
    }

    ### MATCH TABLES IN USAGE TO ALL TABLES

    if (-not $All) {
	
        # Convert $rows to lowercase for case-insensitive comparison
        $rowsLower = $rows | ForEach-Object { $_.ToLower() }
		
        # Filter $AllTables where TableName exists in $rows
        $FilteredTables = $AllTables | Where-Object { $rowsLower -contains $_.TableName.ToLower() }
				
        return $FilteredTables
		
    }
    else {
	
        return $AllTables
    }
}

#			    Update-TablesRetention -TablesForRetention $SelectedTables -TotalRetentionInDays $ArchiveDays -InteractiveInDays $InteractiveDays

function Update-TablesRetention {
    [CmdletBinding()]
    param (        
        [parameter(Mandatory = $true)] $TablesForRetention,		
        [parameter(Mandatory = $true)] $TotalRetentionInDays,
        [parameter(Mandatory = $true)] $InteractiveInDays
    )

    foreach ($tbl in $TablesForRetention) {
        $TablesApi = "https://management.azure.com/subscriptions/$SubscriptionId/resourcegroups/$LogAnalyticsResourceGroup/providers/Microsoft.OperationalInsights/workspaces/$LogAnalyticsWorkspaceName/tables/$($tbl.TableName)" + "?api-version=2025-02-01"		

        $ArchiveDays = [int]($TotalRetentionInDays)
        $InteractiveDays = [int]($InteractiveInDays)

        # Initialize the main hashtable
        $TablesApiBody = @{
            properties = @{}  # Nested hashtable to ensure "properties" is always present
        }

        # Add values only if they are not zero
        if ($InteractiveDays -ne 0) {
            $TablesApiBody.properties["retentionInDays"] = $InteractiveDays
        }

        if ($ArchiveDays -ne 0) {
            $TablesApiBody.properties["totalRetentionInDays"] = $ArchiveDays
        }

        # Convert to JSON
        $TablesApiBodyJson = $TablesApiBody | ConvertTo-Json -Depth 3

        # Output JSON to verify the structure
        #Write-Output $TablesApiBodyJson
		
        try {        
            $TablesApiResult = Invoke-RestMethod -Uri $TablesApi -Method "PATCH" -Headers $LaAPIHeaders -Body $TablesApiBodyJson		
            Write-Log -Message "Table : $($tbl.TableName) updated successfully. Total retention set to $ArchiveDays, Interactive retention set to $InteractiveDays" -LogFileName $LogFileName -Severity Information
        } 
        catch {                    
            Write-Log -Message "Table : $($tbl.TableName) updated failed" -LogFileName $LogFileName -Severity Warning
            Write-Log -Message "Update-TablesRetention $($_)" -LogFileName $LogFileName -Severity Error		                
        }

    }
    return 
}

function Collect-AnalyticsPlanRetentionDays {
    [CmdletBinding()]
    param (        
        [parameter(Mandatory = $true)] $WorkspaceLevelRetention,
        [parameter(Mandatory = $true)] $TableLevelRetentionLimit
    )
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Retention'
    $form.Size = New-Object System.Drawing.Size(380, 350)
    $form.StartPosition = 'CenterScreen'

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(90, 260)
    $okButton.Size = New-Object System.Drawing.Size(75, 30)
    $okButton.Text = 'OK'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)
    $okButton.Enabled = $false    

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(170, 260)
    $cancelButton.Size = New-Object System.Drawing.Size(75, 30)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, 20)
    $label.Size = New-Object System.Drawing.Size(350, 60)
    $label.Text = "TOTAL RETENTION for table(s)`nAllowed values are: [4-730], 1095, 1460, 1826, 2191, 2556, 2922, 3288, 3653, 4018, 4383 days"
    $form.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10, 80)
    $textBox.Size = New-Object System.Drawing.Size(260, 20)
    $textBox.TabIndex = 1
    $form.Controls.Add($textBox)  

    $interactiveLabel = New-Object System.Windows.Forms.Label
    $interactiveLabel.Location = New-Object System.Drawing.Point(10, 130)
    $interactiveLabel.Size = New-Object System.Drawing.Size(350, 60)
    $interactiveLabel.Text = "INTERACTIVE RETENTION for ANALYTICS table(s)`nAllowed values are [4-730] days"
    $form.Controls.Add($interactiveLabel)

    $interactiveTextBox = New-Object System.Windows.Forms.TextBox
    $interactiveTextBox.Location = New-Object System.Drawing.Point(10, 190)
    $interactiveTextBox.Size = New-Object System.Drawing.Size(260, 20)
    $interactiveTextBox.TabIndex = 2
    $form.Controls.Add($interactiveTextBox)

    $textBox.Add_TextChanged({
            $days = [int]$textBox.Text.Trim()
            $AllowedDays = '(1095|1460|1826|2191|2556|2922|3288|3653|4018|4383)'
            if ($days -in 4..730 -or $days -match $AllowedDays) {         
                $okButton.Enabled = $true
                $ErrorProvider.Clear()
            }
            else {
                $ErrorProvider.SetError($textBox, "Allowed values are: [4-730], 1095, 1460, 1826, 2191, 2556, 2922, 3288, 3653, 4018, 4383 days")  
                $okButton.Enabled = $false            
            } 
        }) 

    $interactiveTextBox.Add_TextChanged({
            $interactiveDays = [int]$interactiveTextBox.Text.Trim()
            if ($interactiveDays -in 4..730) {         
                $okButton.Enabled = $true
                $ErrorProvider.Clear()
            }
            else {
                $ErrorProvider.SetError($interactiveTextBox, "Allowed values are: 4-730 days")  
                $okButton.Enabled = $false            
            } 
        }) 

    $ErrorProvider = New-Object System.Windows.Forms.ErrorProvider
    $form.Add_Shown({ $form.Activate() })
    $form.Add_Shown({ $textBox.Select() })
    $form.Topmost = $true    
    $result = $form.ShowDialog()


    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $days = [int]$textBox.Text.Trim()
        $interactiveDays = [int]$interactiveTextBox.Text.Trim()
        return $days, $interactiveDays
    }
    else {
        return 0, 0
    }
	
}

function Get-Confirmation {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $logselectform = New-Object System.Windows.Forms.Form
    $logselectform.Text = 'Confirmation'
    $logselectform.Size = New-Object System.Drawing.Size(250, 160)
    $logselectform.StartPosition = 'CenterScreen'

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, 20)
    $label.Size = New-Object System.Drawing.Size(250, 20)
    $label.Text = 'Do you want to continue?'
    $logselectform.Controls.Add($label)

    $okb = New-Object System.Windows.Forms.Button
    $okb.Location = New-Object System.Drawing.Point(45, 75)
    $okb.Size = New-Object System.Drawing.Size(75, 25)
    $okb.Text = 'Continue'
    $okb.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $logselectform.AcceptButton = $okb
    $logselectform.Controls.Add($okb)

    $cb = New-Object System.Windows.Forms.Button
    $cb.Location = New-Object System.Drawing.Point(135, 75)
    $cb.Size = New-Object System.Drawing.Size(75, 25)
    $cb.Text = 'Exit'
    $cb.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $logselectform.CancelButton = $cb
    $logselectform.Controls.Add($cb)    

    
    $rs = $logselectform.ShowDialog()
    if ($rs -eq [System.Windows.Forms.DialogResult]::OK) {
        return $true
    }
    elseif ($rs -eq [System.Windows.Forms.DialogResult]::Cancel) {
        return $false
    }
}

#endregion

#region DriverProgram
$AzModulesQuestion = "Do you want to update required Az Modules to latest version?"
$AzModulesQuestionChoices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$AzModulesQuestionChoices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$AzModulesQuestionChoices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

$AzModulesQuestionDecision = $Host.UI.PromptForChoice($title, $AzModulesQuestion, $AzModulesQuestionChoices, 1)

if ($AzModulesQuestionDecision -eq 0) {
    $UpdateAzModules = $true
}
else {
    $UpdateAzModules = $false
}

Get-RequiredModules("Az.Accounts")
Get-RequiredModules("Az.OperationalInsights")

$TimeStamp = Get-Date -Format yyyyMMdd_HHmmss 
$LogFileName = '{0}_{1}.csv' -f "Sentinel_Long_Term_Retention", $TimeStamp

# Check Powershell version, needs to be 5 or higher
if ($host.Version.Major -lt 5) {
    Write-Log "Supported PowerShell version for this script is 5 or above" -LogFileName $LogFileName -Severity Error    
    exit
}

#disconnect exiting connections and clearing contexts.
Write-Log "Clearing existing Azure connection" -LogFileName $LogFileName -Severity Information
    
$null = Disconnect-AzAccount -ContextName 'MyAzContext' -ErrorAction SilentlyContinue
    
Write-Log "Clearing existing Azure context `n" -LogFileName $LogFileName -Severity Information
    
get-azcontext -ListAvailable | ForEach-Object { $_ | remove-azcontext -Force -Verbose | Out-Null } #remove all connected content
    
Write-Log "Clearing of existing connection and context completed." -LogFileName $LogFileName -Severity Information
Try {
    #Connect to tenant with context name and save it to variable
    Connect-AzAccount -Tenant $TenantID -ContextName 'MyAzContext' -Force -ErrorAction Stop
        
    #Select subscription to build
    $GetSubscriptions = Get-AzSubscription -TenantId $TenantID | Where-Object { ($_.state -eq 'enabled') } | Out-GridView -Title "Select Subscription to Use" -PassThru       
}
catch {    
    Write-Log "Error When trying to connect to tenant : $($_)" -LogFileName $LogFileName -Severity Error
    exit    
}

## Old non-securestring token aqcuisition
#$AzureAccessToken = (Get-AzAccessToken).Token            
#$LaAPIHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
#$LaAPIHeaders.Add("Content-Type", "application/json")
#$LaAPIHeaders.Add("Authorization", "Bearer $AzureAccessToken")

# Get the access token as a SecureString
$SecureToken = (Get-AzAccessToken -AsSecureString).Token

# Convert SecureString to a plain string
$AzureAccessToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureToken)
)

# Define headers
$LaAPIHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$LaAPIHeaders.Add("Content-Type", "application/json")
$LaAPIHeaders.Add("Authorization", "Bearer $AzureAccessToken")

#loop through each selected subscription.. 
foreach ($CurrentSubscription in $GetSubscriptions) {
    Try {
        #Set context for subscription being built
        $null = Set-AzContext -Subscription $CurrentSubscription.id
        $SubscriptionId = $CurrentSubscription.id
        Write-Log "Working in Subscription: $($CurrentSubscription.Name)" -LogFileName $LogFileName -Severity Information

        $LAWs = Get-AzOperationalInsightsWorkspace | Where-Object { $_.ProvisioningState -eq "Succeeded" } | Select-Object -Property Name, ResourceGroupName, Location | Out-GridView -Title "Select Log Analytics workspace" -PassThru 
        if ($null -eq $LAWs) {
            Write-Log "No Log Analytics workspace found..." -LogFileName $LogFileName -Severity Error 
        }
        else {
            Write-Log "Listing Log Analytics workspace" -LogFileName $LogFileName -Severity Information
                        
            foreach ($LAW in $LAWs) {
                
                $LogAnalyticsWorkspaceName = $LAW.Name
                $LogAnalyticsResourceGroup = $LAW.ResourceGroupName                            
                DO {

                    $SelectedTables = Get-LATables 

                    $WorkspaceRetention = $SelectedTables[0].RetentionInWorkspace

                    $RetentionInDays = Collect-AnalyticsPlanRetentionDays -WorkspaceLevelRetention $WorkspaceRetention -TableLevelRetentionLimit 2555
		    
                    $ArchiveDays = $RetentionInDays[0]
                    $InteractiveDays = $RetentionInDays[1]

                    if ($ArchiveDays -ne 0 -or $InteractiveDays -ne 0) {

                        Update-TablesRetention -TablesForRetention $SelectedTables -TotalRetentionInDays $ArchiveDays -InteractiveInDays $InteractiveDays

                    }

                    $GetConfirmation = Get-Confirmation

                } While ($GetConfirmation -eq $true)
            }                  

        } 	
    }
    catch [Exception] { 
        Write-Log $_ -LogFileName $LogFileName -Severity Error                         		
    }		 
}
#endregion DriverProgram 