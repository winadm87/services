#==============================================
# Zabbix installation automation
# Author Ivanov Artyom
# Created around 2020...
# Version 1.0
#==============================================
# This script is designed to install zabbix agent to windows workstation
# !Don't forget to change computer name which containt zabbix agent!
# Put zaabix*.exe file in some folders on source computer
# For x86 computers rename .exe file like "zabbix_agentd_win32.exe"
# Script will check if system x86 or x64 and copy corresponding .exe's

#set some variables
$computer_with_zabbixagent = "somecomputer"
$SourceFolder = "\\" + $computer_with_zabbixagent + "\soft\zabbix\zabbix_agent"
$TargetFolder = "C:\"
$TargetFolderFullPath = "C:\zabbix_agent"
$serviceName = 'Zabbix Agent'

# Enable firewall rules
netsh advfirewall firewall add rule name="Open Zabbix agentd port 10050 inbound" dir=in action=allow protocol=TCP localport=10050
netsh advfirewall firewall add rule name="Open Zabbix trapper port 10051 inbound" dir=in action=allow protocol=TCP localport=10051
netsh advfirewall firewall add rule name="Open Zabbix agentd port 10050 outbound" dir=out action=allow protocol=TCP localport=10050
netsh advfirewall firewall add rule name="Open Zabbix trapper port 10051 outbound" dir=out action=allow protocol=TCP localport=10051

If (Get-Service $serviceName -ErrorAction SilentlyContinue) {
    If ((Get-Service $serviceName).Status -eq 'Running') {
        Stop-Service $serviceName
        Write-Host "Stopping $serviceName"
		start-sleep 2
		#kill zabbix processes (zabbix_get, zabbix_sender etc) - clear sockets
		Get-Process -Name "*zabbix*" | stop-process -Confirm $false
		#save old config with date in file name, copy new version of agent and config
		$outpath = "C:\zabbix_agent"
		$today = [datetime]::Today
		$oldconf = $outpath + "\" + "zabbix_agentd.conf"
		$oldconfwithdate = $outpath + "\" + "_old_zabbix_agentd" + $($today.ToString('dd-MM-yyyy')) + ".conf"
		Copy-Item $oldconf $oldconfwithdate
		#copy installation folder 
		Copy-Item -Recurse -Path $SourceFolder -Destination $TargetFolder -ErrorAction SilentlyContinue -Force
		#check for os architecture
		IF ((Get-WmiObject Win32_OperatingSystem).OSArchitecture -Like "*32*") {
			Write-Host "System has x32 architecture"
			#set variables
			$x64exepath = $outpath + "\zabbix_agentd.exe"
			$x32exepath = $outpath + "\zabbix_agentd_win32.exe"
			$x64getpath = $outpath + "\zabbix_get.exe"
			$x32getpath = $outpath + "\zabbix_get_win32.exe"
			$x64sendpath = $outpath + "\zabbix_sender.exe"
			$x32sendpath = $outpath + "\zabbix_sender_win32.exe"
			#remove x64 exe and get
			Remove-Item $x64exepath -force 
			Remove-Item $x64getpath -force
			Remove-Item $x64sendpath -force
			#rename x32 exe and get
			Rename-Item -path $x32exepath -newname "zabbix_agentd.exe"
			Rename-Item -path $x32getpath -newname "zabbix_get.exe"
			Rename-Item -path $x32sendpath -newname "zabbix_sender.exe"
		}
		else {
			gci -path $outpath | where{$_.name -like "*win32.exe"} | remove-item -force
		}
		#start the service
		(Get-WmiObject win32_service -Filter "name='Zabbix Agent'").StartService()
    } Else {
        Write-Host "$serviceName found, but it is not running."
		#kill zabbix processes (zabbix_get, zabbix_sender etc) - clear sockets
		Get-Process -Name "*zabbix*" | stop-process -Confirm $false
		#save old config with date in file name, copy new version of agent and config
		$outpath = "C:\zabbix_agent"
		$today = [datetime]::Today
		$oldconf = $outpath + "\" + "zabbix_agentd.conf"
		$oldconfwithdate = $outpath + "\" + "_old_zabbix_agentd" + $($today.ToString('dd-MM-yyyy')) + ".conf"
		Copy-Item $oldconf $oldconfwithdate
		#copy installation folder 
		Copy-Item -Recurse -Path $SourceFolder -Destination $TargetFolder -ErrorAction SilentlyContinue -Force
		#check for os architecture
		IF ((Get-WmiObject Win32_OperatingSystem).OSArchitecture -Like "*32*") {
			Write-Host "System has x32 architecture"
			#set variables
			$x64exepath = $outpath + "\zabbix_agentd.exe"
			$x32exepath = $outpath + "\zabbix_agentd_win32.exe"
			$x64getpath = $outpath + "\zabbix_get.exe"
			$x32getpath = $outpath + "\zabbix_get_win32.exe"
			$x64sendpath = $outpath + "\zabbix_sender.exe"
			$x32sendpath = $outpath + "\zabbix_sender_win32.exe"
			#remove x64 exe and get
			Remove-Item $x64exepath -force 
			Remove-Item $x64getpath -force
			Remove-Item $x64sendpath -force
			#rename x32 exe and get
			Rename-Item -path $x32exepath -newname "zabbix_agentd.exe"
			Rename-Item -path $x32getpath -newname "zabbix_get.exe"
			Rename-Item -path $x32sendpath -newname "zabbix_sender.exe"
		}
		else {
			gci -path $outpath | where{$_.name -like "*win32.exe"} | remove-item -force
		}
		#start the service
		(Get-WmiObject win32_service -Filter "name='Zabbix Agent'").StartService()
    }
} Else {
    Write-Host "$serviceName not found"
	$outpath = "C:\zabbix_agent"
	$today = [datetime]::Today
	Copy-Item -Recurse -Path $SourceFolder -Destination $TargetFolder -ErrorAction SilentlyContinue -Force
	#check for os architecture
	IF ((Get-WmiObject Win32_OperatingSystem).OSArchitecture -Like "*32*") {
		Write-Host "System has x32 architecture"
		#set variables
		$x64exepath = $outpath + "\zabbix_agentd.exe"
		$x32exepath = $outpath + "\zabbix_agentd_win32.exe"
		$x64getpath = $outpath + "\zabbix_get.exe"
		$x32getpath = $outpath + "\zabbix_get_win32.exe"
		$x64sendpath = $outpath + "\zabbix_sender.exe"
		$x32sendpath = $outpath + "\zabbix_sender_win32.exe"
		#remove x64 exe and get
		Remove-Item $x64exepath -force 
		Remove-Item $x64getpath -force
		Remove-Item $x64sendpath -force
		#rename x32 exe and get
		Rename-Item -path $x32exepath -newname "zabbix_agentd.exe"
		Rename-Item -path $x32getpath -newname "zabbix_get.exe"
		Rename-Item -path $x32sendpath -newname "zabbix_sender.exe"
		}
	else {
		gci -path $outpath | where{$_.name -like "*win32.exe"} | remove-item -force
	}
	#create service and start it
	New-Service -Name $serviceName -BinaryPathName "$TargetFolderFullPath\zabbix_agentd.exe --config $TargetFolderFullPath\zabbix_agentd.conf" -DisplayName "Zabbix Agent" -Description "Provides system monitoring" -StartupType "Automatic" -ErrorAction SilentlyContinue
	(Get-WmiObject win32_service -Filter "name='Zabbix Agent'").StartService()
}

	
