
# The Log & Cache Cleaner

## Description

on a busy server, /var/log and /tmp fill up over time so it is crucial to check for disk usage on a regular basis and take action against these directories accordingly to ditch a server crash and downtime! 


### Functionality

1. checks if disk usage on a critical partition (e.g., /) is above a threshold (e.g., 80%).

2. if yes, it finds and deletes log files in /var/log that are older than 30 days (safe to remove).

3. it also empties /tmp of files not accessed in the last 7 days.

4. Finally, it logs what it did, so the admin can review it later!

### Practical Considerations

- disk threshold , targeted partition , max days for log / tmp removal are exposed via variables that are easely configurable for convenience!

- this script is better deployed as a cron job running at hours of minimum server load . so open the crontab of the intended user and insert an entry like this ( this runs every day at 2 AM ): 

```bash
0 2 * * * /path/to/script/disk_cleaner.sh
```
- make sure that script is executable!

```bash
chmod +x /path/to/script/disk_cleaner.sh
```

- lastly , instead of deleting automatically, you can replace -delete with -ls and just send the output of old files to a supervisor/senior so they manually decide what to remove !

Y.



