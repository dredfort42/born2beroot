#!/bin/bash

################################################################################
# Born2beroot Monitoring Script
################################################################################
# Description:
#   This script collects and displays comprehensive system information including
#   hardware specs, resource usage, network details, and security metrics.
#   It broadcasts the information to all logged-in users via the wall command.
#
# Purpose:
#   - Monitor system resources (CPU, RAM, disk usage)
#   - Track security metrics (sudo commands, active connections)
#   - Display system configuration (architecture, LVM status)
#
# Installation:
#   1. Copy script to system directory:
#      sudo cp monitoring.sh /usr/local/bin/
#   2. Make it executable:
#      sudo chmod +x /usr/local/bin/monitoring.sh
#   3. Add to root's crontab for automatic execution every 10 minutes:
#      sudo crontab -e
#      Add line: */10 * * * * /usr/local/bin/monitoring.sh
#
# Requirements:
#   - Linux system with /proc filesystem
#   - Commands: uname, grep, awk, free, df, top, who, lsblk, ss, hostname, 
#               ip, journalctl, wall
################################################################################

################################################################################
# SYSTEM ARCHITECTURE AND KERNEL INFORMATION
################################################################################
# Retrieves complete system information including:
# - Kernel name and version
# - Hardware architecture (x86_64, ARM, etc.)
# - Hostname
# - Kernel release date and version
# Command: uname -a displays all system information at once
################################################################################
arch=$(uname -a)

################################################################################
# PHYSICAL PROCESSOR COUNT
################################################################################
# Counts the number of physical CPU sockets in the system.
# - Searches /proc/cpuinfo for lines containing "physical id"
# - Sorts and removes duplicates (uniq) to count unique physical CPUs
# - Each physical CPU can contain multiple cores
# Example: A server with 2 physical CPUs will return 2
################################################################################
pcpu=$(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l)

################################################################################
# VIRTUAL PROCESSOR (vCPU) COUNT
################################################################################
# Counts the total number of logical processors (threads) available.
# - Each line starting with "processor" in /proc/cpuinfo represents one vCPU
# - Includes all cores and hyperthreading threads
# - This is what the OS sees as available processing units
# Example: A dual-core CPU with hyperthreading shows 4 vCPUs
################################################################################
vcpu=$(grep "^processor" /proc/cpuinfo | wc -l)

################################################################################
# MEMORY (RAM) USAGE STATISTICS
################################################################################
# Collects current RAM usage information in megabytes and percentage.
# 
# ram_total: Total installed RAM in MB
#   - Uses 'free -m' to display memory in megabytes
#   - Extracts second field ($2) from the Mem: line
#
# ram_used: Currently used RAM in MB
#   - Extracts third field ($3) from the Mem: line
#   - Includes cached memory that's actively used by programs
#
# ram_percent: RAM usage as a percentage
#   - Calculates (used/total)*100 with 2 decimal precision
#   - Helps quickly assess if system is running low on memory
################################################################################
ram_total=$(free -m | awk '/^Mem:/ {print $2}')
ram_used=$(free -m | awk '/^Mem:/ {print $3}')
ram_percent=$(free | awk '/^Mem:/ {printf("%.2f"), $3/$2*100}')

################################################################################
# DISK USAGE STATISTICS
################################################################################
# Analyzes disk space usage across all mounted filesystems.
#
# disk_total: Total disk space in Gigabytes
#   - 'df -BG --total' shows sizes in GB blocks and adds a total line
#   - Greps for 'total' line to get aggregate across all filesystems
#   - Removes 'G' suffix to leave only the number
#
# disk_used: Used disk space in Megabytes
#   - 'df -BM --total' shows sizes in MB blocks
#   - Provides more precise used space measurement
#   - Removes 'M' suffix for clean number output
#
# disk_percent: Disk usage as a percentage
#   - Fifth field ($5) contains the percentage
#   - Includes the '%' symbol in the output
#   - Useful for quick capacity planning and alerts
################################################################################
disk_total=$(df -BG --total | grep '^total' | awk '{print $2}' | sed 's/G//')
disk_used=$(df -BM --total | grep '^total' | awk '{print $3}' | sed 's/M//')
disk_percent=$(df --total | grep '^total' | awk '{print $5}')

################################################################################
# CPU LOAD PERCENTAGE
################################################################################
# Calculates current CPU utilization as a percentage.
# - 'top -bn1' runs top in batch mode for one iteration
# - Greps for the '%Cpu' line which contains CPU usage breakdown
# - Adds user time ($2) and system time ($4) for total active CPU usage
# - Formatted to 1 decimal place with '%' symbol
# Note: Does not include idle, wait, or other CPU states
################################################################################
cpu_load=$(top -bn1 | grep '^%Cpu' | awk '{printf("%.1f%%"), $2 + $4}')

################################################################################
# LAST SYSTEM BOOT TIME
################################################################################
# Retrieves the date and time of the last system reboot.
# - 'who -b' shows the last system boot time
# - Extracts the date ($3) and time ($4) fields
# - Useful for tracking system uptime and maintenance windows
################################################################################
last_boot=$(who -b | awk '{print $3, $4}')

################################################################################
# LOGICAL VOLUME MANAGER (LVM) STATUS
################################################################################
# Checks if LVM is active on the system.
# - 'lsblk' lists all block devices and their properties
# - Searches for any device containing "lvm" in the output
# - Returns 'yes' if LVM volumes are found, 'no' otherwise
# - LVM allows flexible disk management (resizing, snapshots, etc.)
################################################################################
lvm_use=$(if [ $(lsblk | grep "lvm" | wc -l) -eq 0 ]; then echo no; else echo yes; fi)

################################################################################
# ACTIVE TCP CONNECTIONS COUNT
################################################################################
# Counts the number of established TCP network connections.
# - 'ss' is the modern replacement for netstat
# - Options: -n (numeric), -e (extended), -o (timer), -p (process), -t (TCP)
# - Filters for 'established' state connections only
# - Counts active connections (excluding listening sockets)
# - Useful for monitoring network activity and potential security issues
################################################################################
tcp_conn=$(ss -neopt state established | wc -l)

################################################################################
# LOGGED-IN USERS COUNT
################################################################################
# Counts the number of currently logged-in users.
# - 'who' displays information about all logged-in users
# - Each line represents one user session
# - Includes SSH sessions, local terminals, and GUI logins
# - Multiple sessions by the same user are counted separately
################################################################################
user_log=$(who | wc -l)

################################################################################
# NETWORK INTERFACE INFORMATION
################################################################################
# Retrieves the primary IPv4 address and MAC address.
#
# ip: Primary IPv4 address
#   - 'hostname -I' lists all IP addresses assigned to the host
#   - First IP ($1) is typically the primary network interface
#   - Usually the address used for network communication
#
# mac: MAC (Media Access Control) address
#   - 'ip link show' displays network interface details
#   - Greps for 'link/ether' which contains the MAC address
#   - MAC address is the hardware address of the network interface
#   - Format: XX:XX:XX:XX:XX:XX (hexadecimal)
################################################################################
ip=$(hostname -I | awk '{print $1}')
mac=$(ip link show | grep "link/ether" | awk '{print $2}')

################################################################################
# SUDO COMMANDS EXECUTED COUNTER
################################################################################
# Counts the total number of commands executed with sudo privileges.
# - 'journalctl' queries the systemd journal (system logs)
# - '_COMM=sudo' filters for entries from the sudo command
# - Greps for 'COMMAND' to find actual command executions
# - Excludes sudo session opens/closes, only counts commands
# - Important security metric for auditing privileged access
# Note: Counter persists across reboots (stored in system journal)
################################################################################
sudo_cmds=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

################################################################################
# BROADCAST SYSTEM INFORMATION
################################################################################
# Uses 'wall' (write all) to broadcast the collected information to all users.
# - Sends message to all logged-in users' terminals
# - Useful for system-wide notifications and monitoring
# - Information is displayed in a formatted, easy-to-read structure
# - Runs automatically via cron every 10 minutes
################################################################################
wall "	#Architecture: $arch
	#CPU physical: $pcpu
	#vCPU: $vcpu
	#Memory Usage: ${ram_used}/${ram_total}MB (${ram_percent}%)
	#Disk Usage: ${disk_used}/${disk_total}Gb (${disk_percent})
	#CPU load: $cpu_load
	#Last boot: $last_boot
	#LVM use: $lvm_use
	#Connexions TCP: $tcp_conn ESTABLISHED
	#User log: $user_log
	#Network: IP $ip ($mac)
	#Sudo: $sudo_cmds cmd"
