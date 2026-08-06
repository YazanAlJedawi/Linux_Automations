Role Description
=========

Automating away the management of linux users, groups, sudo privileges, and SSH authorized keys 
according to one source of truth (a file provided in the playbook) is necessary for every effective Administrator.

This role creates and removes user accounts based on a declarative YAML list. It includes safety checks to ensure SSH key files exist on the control node before deployment, flags missing keys without aborting the workflow, and automatically manages primary/private groups.


**IMPORTANT WARNING**: The Role Assumes and expects the files in the ssh_key_dir path to be the same as defined in the users.yml file.  

Requirements
------------

- Ansible 2.9 or higher

- ansible.posix collection (for authorized_key module)

```bash
ansible-galaxy collection install ansible.posix
```



Role Variables
--------------

- you might want to consider setting these variable when importing the role:

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `userslist_file_path` | `~/Documents/userslist.yml` | The file that includes a list of users and there desired properties |
| `ssh_key_dir` | `~/.ssh/key_dir`  | the path of the directory that contains all public keys of the respective users |
| `manage_password_aging` | true | toggle this setting if you wish to set a password aging policy for the user |
| `password_expire_min` | 7 | minimum days a user must keep a password before they are allowed to change it |
| `password_expire_max` | 90 | after this many days, the user is forced to change their password at next login |



Dependencies
------------

This Role has no dependencies!

Example Playbook
----------------

```yaml
    - hosts: servers
      roles:
         - userlist_creator
         # variables to tweak!!
```

- I left an example of a userlist.yml file in the files/ directory for you to check!

License
-------

MIT

---
