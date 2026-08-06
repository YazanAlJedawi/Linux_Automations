


# Day 1 Server Hardening Role

This is an Ansible role that applies a security baseline to a fresh **Ubuntu/Debian** or **RHEL/CentOS/Rocky** machine, ideally for web services configuration.

it automates the tedious first-day setup so you never have to manually secure a server again.

---

## CRITICAL WARNING: Do NOT lock yourself out!

this role changes the default SSH port and disables password authentication.

**Before running this role, verify the following:**
1. your **SSH public key** is already installed in `~/.ssh/authorized_keys` on the target server.
2. your corporate firewall / cloud Security Group (AWS SG, Azure NSG) **allows inbound traffic on the new port** (`2222` by default).
3. when testing for the first time, **keep two terminal windows open**:
- terminal 1: connected on the old port (22) to run the playbook.
- terminal 2: run `ssh -p <new-port> user@server` to verify the new port works before closing Terminal 1.

**Note**: changing the ssh key might not always be the best choice, some see it as a must, some see it as something
not to play with. I made it so it defaults to the normal 22 port for effeciency.

---

## 📋 What it does

- 🔄 **Updates all system packages** to the latest stable versions.
- 🔑 **Hardens SSH**:
- Changes default port to a custom one (configurable).
- Disables `root` login.
- Disables password authentication (requires SSH keys).
- 🔥 **Configures the firewall** to only allow:
- SSH (on the new custom port)
- HTTP (80)
- HTTPS (443)
- *(Uses UFW for Debian/Ubuntu, Firewalld for RHEL/CentOS)*
- ⏰ **Sets up automatic security updates** using the "guidugli.auto_update" role.

---

## 🖥️ Supported OS Families

 1. Debian/Ubuntu 
 2. RHEL

*The role dynamically detects the OS and applies the correct settings.*


---

## 📁 Role Structure

```text
└── server_hardner
	├── defaults
	│   └── main.yml
	├── files
	├── handlers
	│   └── main.yml
	├── meta
	│   └── main.yml
	├── README.md
	├── tasks
	│   └── main.yml
	├── templates
	│  
	├── tests
	│   ├── inventory
	│   └── test.yml
	└── vars
		├── Debian.yml
		├── main.yml
		└── RedHat.yml
```

---

## 🔧 Configuration Variables

You can override these variables in your playbook or inventory to customize the hardening:

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `ssh_port` | `22` | The port SSH will listen on. |
| `firewalld_zone` | `public`  | the selected firewalld zone on RHEL systems |

Variables to consider for twicking the guidugli.auto_update role :

| Variable | Description |
| :--- | :--- |
| `au_security_only` | this option is set to 'yes' but can be toggled off as needed
| `au_automatic_reboot` | this option is prefered were automatic rebooting and the potential crashing of services is tolerated !
| `au_reboot_time` | in case you toggled the previous setting to 'yes' , setting a time for automatic rebooting is optimal , ex: 2:00 where there is relatively minor load !


---

## 🚀 Usage

### [I] clone the repo

- clone the repository and move the server_hardner directory under the roles/ directory in your ansible project. There are playbook and inventroy examples under the /tests directory.


### [II] Include the role in your playbook

Create a playbook file (e.g., `site.yml`):

```yaml
---
- name: Apply Day 1 Hardening
  hosts: all
  become: yes
  roles:
	- server_hardner
	  # here you change defaults
	- role: guidugli.auto_update
	  # here change any defualts about automatic security updates
```

- don`t forget to define the "guidugli.auto_update" role in your requirements.yml file so you can use it in the playbook:

```yaml
roles:
  - name: guidugli.auto_update
    src: https://github.com/guidugli/ansible-role-auto_update.git
```
then run the command to install requirements:

```bash
 $ ansible-galaxy install -r requirements.yml
```

---

## ✅ Verification (What to check after running)

- SSH on new port: `ssh -p <ssh-port> user@your-server`
- Firewall rules:
- Debian: `sudo ufw status`
- RHEL: `sudo firewall-cmd --list-all`
- Auto-update status:
- Debian: `sudo systemctl status unattended-upgrades`
- RHEL: `sudo systemctl status dnf-automatic.timer`

---

