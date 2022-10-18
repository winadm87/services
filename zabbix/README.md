# Zabbix 
This directory contains usefull things for zabbix.
- zabbix_templates - some custom zabbix templates, exported from zabbix 5.2.6.
- zabbix_regular_expressions - list of regular expressions, needed by templates
- agent_scripts - some custom scripts to place into systemroot\zabbix_agent\scripts folder.
- install_zabbix_agent_x32_x64.ps1 - script to automate zabbix agent installation to windows ws\servers
- update_zabbix_agents_in_parallel.ps1 - script ot automate zabbix agent and zabbix config update. script configured to run in parallel on all discovered AD computer objects.

## Templates
All templates exported from 5.2.6 zbx version
- zbx_Microsoft_Exchange_Server_2016_Queues.yaml - monitor ms exchange 2016 queues, trigger notification on too big queue
- zbx_Windows_Eventlog_common_simple_triggers.yaml - collect and trigger on main windows events
- zbx_Windows_Eventlog_Domain_Controller_simple_triggers.yaml - collect and trigger on windows AD contoller
- zbx_Windows_Eventlog_RDP_login_monitor.yaml - collect and trigger on RDP login
- zbx_Windows_Eventlog_Security_Workstations.yaml - collect and trigger events on built-in admin login to windows computer
- zbx_Windows_Eventlog_VEEAM_simple_triggers.yaml - collect and trigger windows events about veeam backup jobs
- zbx_Windows_Task_Scheduler.yaml - monitor windows tash scheduler. look for posh script in neighbour directory

