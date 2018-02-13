<#
        .Synopsis
        Shows the status of the SSH service
        .Description
        Retrieves the status of the SSH service of VMHosts provided, or VMHosts in the cluster provided
        .Parameter VMHosts
        The VMHosts you want to get the SSH service status of. Can be a single host or multiple hosts provided by the pipeline
        .Example
        Get-VMHostSSHServiceStatus
        Shows the SSH service status of all VMHosts in your vCenter
        .Example
        Get-VMHostSSHServiceStatus vmhost1
        Shows the SSH service status of vmhost1
        .Example
        Get-VMHostSSHServiceStatus -cluster cluster1
        Shows the SSH service status of all vmhosts in cluster1
        .Example
        Get-VMHost -location folder1 | Get-VMHostSSHServiceStatus
        Shows the SSH service status of VMHosts in folder1
        .Link
        https://github.com/Dapacruz/VMware.VimAutomation.Custom
#>
function Get-VMHostSSHServiceStatus {
    [CmdletBinding()] 
    Param (
        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory=$False, Position=0)]
        [Alias('Name')]
        [string[]]$VMHosts,

        [parameter(Mandatory=$False)]
        [string]$Cluster
    )
    Process {
        If ($VMHosts) {
            foreach ($VMHost in $VMHosts) {
                get-vmhostservice $VMHost | Where-Object { $_.key -eq "tsm-ssh" } | Select-Object VMHost, Label, Running
            }
        }
        elseif ($Cluster) {
            foreach ($VMHost in (Get-VMHost -Location $Cluster)) {
                get-vmhostservice $VMHost | Where-Object { $_.key -eq "tsm-ssh" } | Select-Object VMHost, Label, Running
            }
        }
        else {
            get-vmhostservice '*' | Where-Object { $_.key -eq "tsm-ssh" } | Select-Object VMHost, Label, Running
        }
    }
}
