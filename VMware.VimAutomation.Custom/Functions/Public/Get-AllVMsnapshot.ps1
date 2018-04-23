<#
        .Synopsis
        Scans for all snapshots including hidden ones on all VM's, or selected ones.
        .Description
        Returns a list of snapshots that include hidden and visible ones. Invisble snapshots are considered snapshots that can only be found by searching the VMFS file system for *delta* files.
        Pipeline support is included. 
        .Example
        get-allvmsnapshot
        Returns the total number of VM's with snapshots as well as a list of VM's with hidden snapshots. 

        get-allvmsnapshot -VM "myguestvm"
        Returns snapshot information about the selected vm.
        .Link
        
#>
function get-allvmsnapshot {

    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position=0)][Alias('Name')]
        [string[]]$VM = '*'
    )


$final = @()
$snapshotfinal = @()
$vmlist = get-vm $VM
 
#Get a list of all VM's with known snapshots
foreach ($v in $vmlist){
    if (get-snapshot $v){
        $snapshotfinal += $v.name
    }
}

#Get all VM's with delta disks
foreach ($v in $vmlist){
    $delta = $v.extensiondata.layoutex.file | where-object {$_.Name -like "*delta*"} | select-object -first 1
    if ($delta){
        $final += $v.name
    }
}

#Compare $Final with $snapshots

$vcount = $snapshotfinal.count
$icount = $final.count - $snapshotfinal.count
Write-Output "Total number of VM's with visible snapshots: $vcount"
write-output "Total number of VM's invisible snapshots: $icount"
write-output "`nYou have hidden snapshots on the follow VM's:`n"
$diff = Compare-Object $final $snapshotfinal | ?{$_.SideIndicator -eq '<='} | select InputObject 
foreach  ($d in $diff){write-output $d.inputobject}

}

