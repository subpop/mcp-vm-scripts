#!/usr/bin/osascript

on run argv
    -- Validate arguments
    if (count of argv) is less than 1 then
        return "Error: You must provide the VM name as an argument"
    end if

    set vmName to item 1 of argv

    tell application "UTM"
        try
            -- Find the virtual machine by name
            set targetVM to first virtual machine whose name is vmName

            -- Check if VM is running
            if status of targetVM is not started then
                return ""
            end if

            -- Get configuration
            set vmConfig to configuration of targetVM

            -- Get network interfaces
            set netInterfaces to network interfaces of vmConfig

            -- Try to get IP from first network interface
            if (count of netInterfaces) > 0 then
                set firstInterface to item 1 of netInterfaces

                -- Try to get IPv4 address
                try
                    set ipAddress to IPv4 address of firstInterface
                    if ipAddress is not missing value and ipAddress is not "" then
                        return ipAddress
                    end if
                end try
            end if

            -- If we couldn't get IP from configuration, return empty string
            return ""

        on error errMsg
            -- VM not found or other error
            return ""
        end try
    end tell
end run
