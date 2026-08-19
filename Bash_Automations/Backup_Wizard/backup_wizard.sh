#!/bin/bash
# Author: Yazan AlJedawi , https://github.com/YazanAlJedawi
# Created: 14.8.2026
# Modified: Not yet!
# Description:
# Backups are a repetetive yet essential part in the Admin day-to-day workflow, so this task is obviously better to be automated 
# away . This tiny lightweight script does just that!


RETENTION_DAYS=14
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"



while getopts "t:d:" opt; do
  case "$opt" in 
    
    t) BACKUP_DIR=$OPTARG
    ;; 
    d) BACKUP_DESTINATION=$OPTARG
    ;;
    \?) Echo "Invalid option provided!!
              Options are:
              -t   followed by the directory intended to be backed-up.
              -d   followed by the path to directory were the backup is desired to land. 
              "
    ;;
  esac
done

# check if both options were given
if [ -z "$BACKUP_DIR" ] || [ -z "$BACKUP_DESTINATION" ]; then
  echo "Missing important options:
      Options are:
            -t   followed by the path directory intended to be backed-up.
            -d   followed by the path to directory were the backup is desired to land.
      
      [$] These are mandatory to provide !! 
      "
  exit 1
fi

# verify source directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Error: Source directory '$BACKUP_DIR' does not exist."
    exit 1
fi


mkdir -p "$BACKUP_DESTINATION"

tar -czf "$BACKUP_DESTINATION/Backup_Wizard.${TIMESTAMP}.tar.gz" "$BACKUP_DIR"

# delete all backups that aren`t modified within a specified number of days 
find "$BACKUP_DESTINATION" -type f -name 'Backup_Wizard.*.tar.gz' -mtime "+${RETENTION_DAYS}" -delete

echo "BACKUP COMPLETE !!"
