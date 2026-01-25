#!/usr/bin/osascript

on run argv
    -- 1. VALIDATE ARGUMENTS
    if (count of argv) is less than 3 then
        return "Error: You must provide three arguments: <vm-name> <path-to-qcow2> <path-to-iso>"
    end if

    set vmName to item 1 of argv
    set qcowPath to item 2 of argv
    set isoPath to item 3 of argv

    -- CONFIGURATION VARIABLES
    set vmArch to "aarch64"
    set vmMemory to 4096
    
    tell application "UTM"
        try
            -- 2. DEFINE DRIVES
            set osDrive to {removable:false, source:(POSIX file qcowPath), interface:"virtio"}
            set cloudInitDrive to {removable:true, source:(POSIX file isoPath), interface:"usb"}
            
            -- 3. DEFINE NETWORK
            -- mode: shared -> Corresponds to "Shared Network" (vmnet-shared)
            -- mode: bridged -> Corresponds to "Bridged" (vmnet-bridged)
            -- hardware: "virtio-net-pci" -> Standard for Linux performance
            set netInterface to {mode:shared, hardware:"virtio-net-pci"}
            
            -- 4. COMPILE CONFIGURATION
            -- We add the 'network interfaces' list to the config record
            set vmConfig to {name:vmName, architecture:vmArch, memory:vmMemory, drives:{osDrive, cloudInitDrive}, network interfaces:{netInterface}}
            
            -- 5. CREATE VM (QEMU Backend)
            set newVM to make new virtual machine with properties {backend:qemu, configuration:vmConfig}
            
            -- 6. START VM
            start newVM
            
            return "Success: VM '" & vmName & "' started with Shared Network."
            
        on error errMsg
            return "Error: " & errMsg
        end try
    end tell
end run
