# VMware.VimAutomation.Custom
*Extends the functionality of VMware PowerCLI*  

**Get-VMHostSSHServiceStatus**  
Retrieves the status of the SSH service of VMHosts provided, or VMHosts in the cluster provided

**Start-VMHostSSHService**  
Starts the SSH service of VMHosts provided, or VMHosts in the cluster provided

**Stop-VMHostSSHService**  
Stops the SSH service of VMHosts provided, or VMHosts in the cluster provided

**Get-VMHostUptime (included, but not developed by me)**  
Calculates the uptime of VMHosts provided, or VMHosts in the cluster provided

**Get-VMHostDatastores**  
Retrieves the datastore usage of VMHosts provided

**New-VMHostNetworkingCsvTemplate**  
Creates a set of host networking CSV import templates to be used with Import-VMHostNetworkingFromCsv

**Export-VMHostNetworkingToCsv**  
Exports host networking of VMHosts provided

**Import-VMHostNetworkingFromCsv**  
Imports host networking for VMHosts provided utilizing the output from Export-VMHostNetworking

**Enable-VMHostIscsiAdapter**  
Enables and configures the software iSCSI adapter

**Test-VMHostNetworking**  
Pings addresses from each provided VMkernel port of VMHosts provided

**Get-VMHostCpuRatio**  
Calculates the virtual to physical CPU ratio of VMHosts provided

**Get-VMHostNetworkCdpInfo**  
Displays the CDP info for each vmnic of VMHosts provided

**Get-VMHostNetworkLldpInfo**  
Displays the LLDP info for each vmnic of VMHosts provided

**Get-VMCpuReadyPercent**  
Calculates the CPU ready percent average of virtual machines provided

<br />

Installation
--------------
Download, unzip and copy the VMware.VimAutomation.Custom subfolder to $home\Documents\WindowsPowerShell\Modules\
