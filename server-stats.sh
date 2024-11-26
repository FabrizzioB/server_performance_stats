#!/bin/bash
# Analyze server performance stats

while : 
do
    # Get CPU usage (idle percentage subtracted from 100)
    cpuIdle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}')
    cpuUsage=$(echo "100 - $cpuIdle" | bc)

    # Memory stats
    memStats=$(free -m | awk '/Mem/{printf "%d %d %d", $3, $7, $2}')
    memUsage=$(echo $memStats | awk '{print $1}')      # Used memory
    memAvailable=$(echo $memStats | awk '{print $2}')  # Available memory
    memTotal=$(echo $memStats | awk '{print $3}')      # Total memory
    memPercent=$(echo "scale=2; $memUsage / $memTotal * 100" | bc)

    # Get disk stats
    diskStats=$(df -H / | awk 'NR==2 {print $2, $3, $4, $5}')
    diskTotal=$(echo $diskStats | awk '{print $1}')    # Total disk size
    diskUsed=$(echo $diskStats | awk '{print $2}')     # Used disk space
    diskFree=$(echo $diskStats | awk '{print $3}')     # Free disk space
    diskPercent=$(echo $diskStats | awk '{print $4}')  # Used percentage

    # Top 5 processes by CPU usage
    topCpu=$(ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6 | awk 'NR>1 {printf "PID: %-8s %-20s CPU: %s%%\n", $1, $2, $3}')

    # Top 5 processes by memory usage
    topMem=$(ps -eo pid,comm,%mem --sort=-%mem | head -n 6 | awk 'NR>1 {printf "PID: %-8s %-20s MEM: %s%%\n", $1, $2, $3}')

    # Stretch Goal: Additional Stats
    osVersion=$(lsb_release -d | awk -F'\t' '{print $2}')  # OS version
    uptime=$(uptime -p)                                   # Uptime in human-readable format
    loadAvg=$(uptime | awk -F'load average:' '{print $2}') # Load average
    loggedInUsers=$(who | wc -l)                          # Number of logged-in users
    failedLogins=$(grep "Failed password" /var/log/auth.log 2>/dev/null | wc -l) # Failed login attempts

    # Clear the screen for better readability
    clear

    # Print the usage
    echo "Server Performance Stats (updated every second):"
    echo "----------------------------------------------"
    echo "CPU Usage: $cpuUsage%"

    echo "Memory Free: $memAvailable MB"
    echo "Memory Usage: $memUsage MB"
    echo "Memory Used Percentage: $memPercent%"
    
    echo "Disk Total: $diskTotal"
    echo "Disk Used: $diskUsed"
    echo "Disk Free: $diskFree"
    echo "Disk Usage Percentage: $diskPercent"

    echo ""
    echo "Top 5 Processes by CPU Usage:"
    echo "-----------------------------"
    echo "$topCpu"
    echo ""

    echo "Top 5 Processes by Memory Usage:"
    echo "--------------------------------"
    echo "$topMem"
    echo ""
    
    echo "System Information:"
    echo "-------------------"
    echo "OS Version: $osVersion"
    echo "Uptime: $uptime"
    echo "Load Average: $loadAvg"
    echo "Logged-in Users: $loggedInUsers"
    echo "Failed Login Attempts: $failedLogins"

    # Sleep
    sleep 1
done
