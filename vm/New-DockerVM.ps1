# -----------------------------------------------------------------------------
# Script Name: New-DockerVM.ps1
# Description:
#   This script automates the creation and clustering of a new Hyper-V virtual
#   machine on a specified node within a Windows Failover Cluster.
#
#   Steps performed:
#     1. Defines configuration variables for cluster, node, VM, ISO, storage,
#        CPU, memory, disk size, and VLAN.
#     2. Uses Invoke-Command to remotely:
#        - Ensure required directories exist for VM and VHD.
#        - Create a new Generation 2 VM with specified resources.
#        - Create and attach a dynamically expanding VHDX file.
#        - Attach the specified ISO as a DVD drive.
#        - Configure firmware for secure boot.
#        - Set up the VM’s network adapter with the specified VLAN and connect
#          it to a virtual switch.
#        - Configure automatic start and stop actions for the VM.
#     3. Waits briefly to ensure VM registration.
#     4. Adds the VM to the specified cluster as a clustered role.
#
#   Intended for automated, repeatable VM provisioning in clustered Hyper-V
#   environments.

$cluster = "cluster-1.domain.com"
$node = "host-1-cluster-1.domain.com"
$vm = "docker-1.domain.com"
$iso = "C:\ClusterStorage\Volume1\Setup\ubuntu-24.04.2-live-server-amd64.iso"
$storage = "C:\ClusterStorage\Volume3"
$cpu = 4
$memory = 8GB
$size = 256GB
$vlan = 311

Invoke-Command -ComputerName $node -ScriptBlock {
    param(
        $vm, $iso, $storage, $cpu, $memory, $size, $vlan
    )
    $vm_path = "$storage\Hyper-V\$vm\Virtual Machines"
    $vhd_path = "$storage\Hyper-V\$vm\Virtual Hard Disks\$vm-sda.vhdx"

    # Ensure directories exist
    if (-not (Test-Path $vm_path)) {
        New-Item -Path $vm_path -ItemType Directory -Force | Out-Null
    }
    $vhd_dir = Split-Path $vhd_path
    if (-not (Test-Path $vhd_dir)) {
        New-Item -Path $vhd_dir -ItemType Directory -Force | Out-Null
    }

    # Create VM
    New-VM -Name $vm `
        -MemoryStartupBytes $memory -Generation 2 -Path $vm_path
    Set-VM -Name $vm `
        -ProcessorCount $cpu -MemoryStartupBytes $Memory

    # Create and attach VHD
    New-VHD -Path $vhd_path `
        -SizeBytes $size -Dynamic -BlockSizeBytes 1MB
    Add-VMHardDiskDrive -VMName $vm -Path $vhd_path

    # Attach ISO
    Add-VMDvdDrive -VMName $vm -Path $iso

    # Firmware and network
    Set-VMFirmware -VMName $vm `
        -EnableSecureBoot On -SecureBootTemplate MicrosoftUEFICertificateAuthority
    Set-VMNetworkAdapterVlan -VMName $vm -Access -VlanId $vlan
    Connect-VMNetworkAdapter -VMName $vm -SwitchName "vSwitch"

    # Startup/Shutdown actions
    Set-VM -Name $vm -AutomaticStartAction Start -AutomaticStartDelay 30 -AutomaticStopAction Save
} -ArgumentList $vm, $iso, $storage, $cpu, $memory, $size, $vlan

# Wait for VM registration before adding to cluster
Start-Sleep -Seconds 5

Add-ClusterVirtualMachineRole -Cluster $cluster -VMName $vm
