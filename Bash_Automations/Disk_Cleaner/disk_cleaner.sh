#!/bin/bash
# Author: Yazan AlJedawi , https://github.com/YazanAlJedawi
# Created: 10.8.2026
# Modified: Not yet!
# Description: 
# on a busy server, /var/log and /tmp fill up over time so it is crucial to check for disk usage on a regular basis 
# and take action against these directories accordingly to ditch a server crash and downtime! 


threshold=80
partition="/"
log_directory="/var/log"
tmp_directory="/tmp"
days_logs=30
days_tmp=7
log_file="/var/log/disk_cleaner.log"

# getting current disk usage
usage=$(df -h "$partition" | awk 'NR==2 {print $5}' | sed 's/%//')

# check for exeeding the threshold
if [ "$USAGE" -gt "$THRESHOLD" ]; then
    echo "$(date): Disk usage is ${USAGE}% — starting cleanup ..." >> "$log_file"
    
    # delete old log 
    find "$log_directory" -name "*.log" -type f -mtime +"$DAYS_LOGS" -delete 2>/dev/null
    echo "  Removed logs older than $days_logs days from $log_directory" >> "$log_file"
    
    # clean /tmp of old unused files
    find "$" -type f -atime +"$days_tmp" -delete 2>/dev/null
    echo "  Removed files from $tmp_directroy that are not accessed in $days_tmp days" >> "$log_file"
    
    # show new usage
    new_usage=$(df -h "$partition" | awk 'NR==2 {print $5}' | sed 's/%//')
    echo "$(date): Cleanup done. New usage: ${new_usage}%" >> "$log_file"
else
    echo "$(date): Disk at ${usage}% — below threshold, back to sleep ZzZzZ....." >> "$log_file"
fi