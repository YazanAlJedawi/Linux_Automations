# RHEL Security Audit Script

A lightweight Bash script that checks a RHEL/CentOS system against five essential security best practices  
It produces a clear {Pass/Fail} report and **does not** change any settings automatically.

---

## What It Checks

| # | Check | Criteria for PASS |
| :--- | :--- | :--- |
| 1 | **Root SSH login** | `PermitRootLogin no` is set in `/etc/ssh/sshd_config` (uncommented) |
| 2 | **World‑writable files in `/etc`** | No regular files with the “others write” permission bit |
| 3 | **Firewall status** | `firewalld` service is active and running |
| 4 | **Password expiration policy** | `PASS_MAX_DAYS` in `/etc/login.defs` is set to a value between 1 and 90 |
| 5 | **SELinux mode** | SELinux is in Enforcing mode |

**Notes:**

> the script is intentionally RHEL‑centric. For other distributions, adjust the firewall and SELinux checks accordingly.

> in order for the script to probe for this metrices , it needs root privileges!

> in case the script found world-writable files in /etc , it would list them in a file called "etc_writable_by_others.txt" in the same directory of the script.
---

## Installation

1. Download or copy the script into a file, e.g. `security_audit.sh`:

2. give it execute permissions:

```bash
chmod 744 sec_audit.sh
```

3. run is as root:

```bash
sudo ./sec_audit.sh
```

- and just like that , you have a more secure server ! 

Y.
