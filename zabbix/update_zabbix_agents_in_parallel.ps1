#======================================
# This piece of code updates list of grepped AD servers\ws
# Config and exe's
# Author Artyom Ivanov
# Created around 2019...
# Version 1.0
# =====================================

#use the workflow keyword (it's very similar to a function)
workflow update-zabbix-agent {
	#Set the list of servers on which to run the command
	$servers = Get-ADComputer -Filter {enabled -eq "true" -and OperatingSystem -notLike 'Windows Server 2003'} -properties * | sort Name | select -ExpandProperty Name
	#The foreach -parallel command
		foreach -parallel ($server in $servers){
			if (Test-Connection -Computername $server -BufferSize 16 -Count 1 -Quiet) {
				#Use the sequence keyword, to ensure everything inside of it runs in order on each server.
				sequence {
					"Starting $server"
					#Use the inlinescript keyword to allow PowerShell workflow to run regular PowerShell cmdlets
					#example
					#      inlineScript{
					#			Invoke-Command -serverName $Using:server -ScriptBlock {gpupdate /force}
					#      }
					inlineScript{
						Invoke-Command -ComputerName $Using:server -ScriptBlock {
						net stop "zabbix agent"
						start-sleep 5
						# kill zabbix processes (zabbix_get, zabbix_sender etc) - clear sockets
						Get-Process -Name "*zabbix*" | stop-process -Confirm $false
						}
						# wait a while
						start-sleep 1
						#save old config with date in file name, copy new version of agent and config
						$outpath = "\\" + $Using:server + "\c$\zabbix_agent"
						$today = [datetime]::Today
						$oldconf = $outpath + "\" + "zabbix_agentd.conf"
						$oldconfwithdate = $outpath + "\" + "_old_zabbix_agentd" + $($today.ToString('dd-MM-yyyy')) + ".conf"
						Copy-Item $oldconf $oldconfwithdate
						robocopy \\COMPUTER_WITH_NEW_ZABBIX_AGENT\soft\zabbix\zabbix_agent_ws $outpath /E /COPY:DATSO /Z /R:5 /W:15 /R:3 /NP
						#check architecture and set x32 files instead of x64
							if ((Get-WmiObject -ComputerName $Using:server Win32_OperatingSystem).OSArchitecture -Like "*32*") {
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
						#wait a while
						start-sleep 1
						#start agent
						Invoke-Command -ComputerName $Using:server -ScriptBlock {
						net start "zabbix agent"
						}
					}
				"$server done"
				}
			}

		}

} 

update-zabbix-agent
