
# Description

 Backups are a repetetive yet essential part in the Admin day-to-day workflow, so this task is obviously better to be automated 
 away . This tiny lightweight script does just that!


# Functionality

```text
backup_wisard.sh -t <target directory for backup> -d <desired destination>
```

- make sure that script is executable!

```bash
chmod +x /path/to/script/backup_wisard.sh
```

- this script is idealy accompanied with a cron job for consistency , so open the crontab of the intended user and insert an entry like this ( this runs every thursday at 2 AM ): 

```bash
0 2 * * thu /path/to/script/backup_wisard.sh
```

- it also stores the archived backup with timestamps and is generous enough to delete older backups and prevent unnecessarely redundant files!
 
  

Y.

