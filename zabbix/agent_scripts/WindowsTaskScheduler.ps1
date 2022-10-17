# Add to Zabbix Agent
# UserParameter=WindowsTaskScheduler[*],powershell -NoProfile -ExecutionPolicy Bypass -File "C:\zabbix_agent\scripts\WindowsTaskScheduler.ps1" "$1" "$2"

# Set function for rus encoding in zabbix
function Convert-Encoding
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline = $true)]
        $InputObject,
        [Parameter(Position = 0)]
        [String]
        $From,
        [Parameter(Position = 1)]
        [String]
        $To
    )
    begin
    {
        if ($From)
        {
            $EncodingFrom = [System.Text.Encoding]::GetEncoding($From)
        }
        else
        {
            $EncodingFrom = $OutputEncoding
        }
        if ($To)
        {
            $EncodingTo = [System.Text.Encoding]::GetEncoding($To)
        }
        else
        {
            $EncodingTo = $OutputEncoding
        }
        $Content = @()
    }
    process
    {
        $Content += $InputObject
    }
    end
    {
        $Content = $Content | Out-String
        $Bytes = $EncodingTo.GetBytes($Content)
        $Bytes = [System.Text.Encoding]::Convert($EncodingFrom, $EncodingTo, $Bytes)
        $Content = $EncodingTo.GetString($Bytes)
        return $Content
    }
}

# Read arguments from zabbix discovery and items. First argument goes to SWITCH, second 
# takes task name and get parameter
$ITEM = [string]$args[0]
$ID = [string]$args[1]

function Connect-ToTaskScheduler
{
    <#
    .Synopsis
        Connects to the scheduler service on a computer
    .Description
        Connects to the scheduler service on a computer
    .Example
        Connect-ToTaskScheduler
    #>
    param(
    # The name of the computer to connect to.
    $ComputerName,
    
    # The credential used to connect
    [Management.Automation.PSCredential]
    $Credential    
    )   
    
    $scheduler = New-Object -ComObject Schedule.Service
    if ($Credential) { 
        $NetworkCredential = $Credential.GetNetworkCredential()
        $scheduler.Connect($ComputerName, 
            $NetworkCredential.UserName, 
            $NetworkCredential.Domain, 
            $NetworkCredential.Password)            
    } else {
        $scheduler.Connect($ComputerName)        
    }    
    $scheduler
}
function Get-ScheduledTask
{
    <#
    .Synopsis
        Gets tasks scheduled on the computer
    .Description
        Gets scheduled tasks that are registered on a computer
    .Example
        Get-ScheduleTask -Recurse
    #>
    param(
    # The name or name pattern of the scheduled task
    [Parameter()]
    $Name = "*",
    
    # The folder the scheduled task is in
    [Parameter()]
    [String[]]
    $Folder = "",
    
    # If this is set, hidden tasks will also be shown.  
    # By default, only tasks that are not marked by Task Scheduler as hidden are shown.
    [Switch]
    $Hidden,    
    
    # The name of the computer to connect to.
    $ComputerName,
    
    # The credential used to connect
    [Management.Automation.PSCredential]
    $Credential,
    
    # If set, will get tasks recursively beneath the specified folder
    [switch]
    $Recurse
    )
    
    process {
        $scheduler = Connect-ToTaskScheduler -ComputerName $ComputerName -Credential $Credential            
        $taskFolder = $scheduler.GetFolder($folder)
        $taskFolder.GetTasks($Hidden -as [bool]) | Where-Object {
            $_.Name -like $name
        }
        if ($Recurse) {
            $taskFolder.GetFolders(0) | ForEach-Object {
                $psBoundParameters.Folder = $_.Path
                Get-ScheduledTask @psBoundParameters
            }
        }        
    }
} 




# Use switch to minimize scripts in zabbix directory.  
switch ($ITEM) {
  "DiscoverTasks" {
    $tasks = @{
      'data' = @(
        Get-ScheduledTask | where {($_.Name -notlike "*Optimize*") -and ($_.Name -notlike "Обновление браузера*")`
																   -and ($_.Name -notlike "CreateExplorerShellUnelevatedTask")`
																   -and ($_.Name -notlike "*HPLJCustParticipation*")`
																   -and ($_.Name -notlike "*RtkAudUService64_BG*")`
																   -and ($_.Name -notlike "*User_Feed*")`
																   -and ($_.Name -notlike "RtHDVBg_PushButton")`
																   -and ($_.Name -notlike "nvbattery*")`
																   -and ($_.Name -notlike "nvtm*")`
																   -and ($_.Name -notlike "nvprofile*")`
																   -and ($_.Name -notlike "nvnode*")`
																   -and ($_.Name -notlike "nvidia*")`
																   -and ($_.Name -notlike "nvdriver*")`
																   -and ($_.Name -notlike "gpu tweak*")`
																   -and ($_.Name -notlike "ccleaner*")`
																   -and ($_.Name -notlike "dropbox*")`
																   -and ($_.Name -notlike "*Yandex*")`
																   -and ($_.Name -notlike "*яндекс*")`
																   -and ($_.Name -notlike "*Adobe*")`
																   -and ($_.Name -notlike "*GoogleUpdate*")`
																   -and ($_.Name -notlike "*Netwrix*")`
																   -and ($_.Name -notlike "*Yandex Browser*")`
																   -and ($_.Name -notlike "Opera*")`
																   -and ($_.Name -notlike "MicrosoftEdgeUpdate*")`
																   -and ($_.Name -notlike "OneDrive*")`
																   -and ($_.Name -notlike "SensorFramework-*")`
																   -and ($_.Name -notlike "RtkAudUService-*")`
																   -and ($_.Name -notlike "update-sys")`
																   -and ($_.Name -notlike "update-S-1-5-21*")`
																   -and ($_.Name -notlike "*браузера*")`
																   -and ($_.Name -notlike "Kontur.Plugin*")`
																   -and ($_.Name -notlike "GoogleUpdate*")`
																   -and ($_.Name -notlike "MicrosoftEdgeUpdateTaskUser*")`
																   -and ($_.Name -notlike "GroupSync")`
																   -and ($_.Name -notlike "Kontur.Updater*")`
																   -and ($_.Name -notlike "*HP Officejet 7110 series.exe*")} | % {
	      @{ '{#TASKID}' = $_.Name
	      }
	    }
      )
    } | ConvertTo-Json | Convert-Encoding -From CP866 -To UTF-8
    [Console]::WriteLine( $tasks )
  }

  "TaskLastResult" {
    [string] $name = $ID
	$taskResult = Get-ScheduledTask $name | select -ExpandProperty LastTaskResult
	Write-Output ($taskResult)
  }

  "TaskLastRunTime" {
    [string] $name = $ID
	$DateLastRun = Get-ScheduledTask $name | select -ExpandProperty LastRunTime
    $DateLastRun1 = $DateLastRun.DateTime | Convert-Encoding -From CP866 -To UTF-8
	Write-Output ($DateLastRun1)
  }

  "TaskNextRunTime" {
    [string] $name = $ID
	$DateNextRun = Get-ScheduledTask $name | select -ExpandProperty NextRunTime
    $DateNextRun1 = $DateNextRun.DateTime | Convert-Encoding -From CP866 -To UTF-8
	Write-Output ($DateNextRun1)
  }
}


