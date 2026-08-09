
#  Secure Containerized Web Gateway 

An Automation project demonstrating the deployment of a secure, multi-tier microservice architecture using **Ansible** and **Podman**. 

This project automates the provisioning of two separate Linux servers: a public-facing Web Tier and a strictly isolated Database Tier, communicating securely over a physical network.

## Architecture Overview

This deployment follows the principle of **least privilege** and **network segmentation**. the application is split across two distinct servers, ensuring that a compromise of the public web server does not grant an attacker direct access to the database. 



```text
           [ The Internet ]
                  │
                  │ HTTPS (Port 443)
                  ▼
┌─────────────────────────────────────────┐
│  WEB SERVER (Nginx + Flask)             │
│  -------------------------------------  │
│                                         │
│   [ Nginx (Reverse Proxy + SSL) ]       │
│            │                            │
│            │ Internal Podman Network    |
│            ▼                            │
│   [ Flask (Web App) ]                   │
│                                         │
└─────────────────┬───────────────────────┘
                  │
                  │ TCP (Port 5432)
                  │ Allowed ONLY via iptable forward rule
                  │
┌─────────────────▼───────────────────────┐
│           DATABASE SERVER               │
│  -------------------------------------  │
│                                         │
│            [ PostgreSQL DB ]            │
│                                         │
└─────────────────────────────────────────┘
```

### Key Security Features
*   **Network Isolation:** the database server is not exposed to the internet. It only accepts connections on port `5432` from the Web Server's specific IP address.
*   **Firewalld Rich Rules:** Uses `firewalld` to dynamically whitelist the Web Server's IP on the Database server.
*   **Reverse Proxy:** nginx handles SSL termination and routes traffic, hiding the internal Flask application ports.
*   **Daemonless Containers:** utilizes **Podman** instead of Docker, removing the need for a privileged, always-running daemon (`dockerd`).

## 🛠️ Tech Stack

*   **Automation:** Ansible Core
*   **Container Engine:** Podman (via `containers.podman` collection)
*   **Reverse Proxy:** Nginx
*   **Backend:** Python / Flask
*   **Database:** PostgreSQL 
*   **OS:** CentOS Stream / RHEL / Rocky Linux / AlmaLinux
*   **Firewall:** firewalld (via `ansible.posix` collection)


## Important Considerations!


> **Note:** this project generates **Self-Signed SSL Certificates** dynamically on the web server for ease of deployment in a lab or development environment. browsers will display a "Not Secure" warning. This is expected for this lab.  **For Production:** You should replace the self-signed task with Let's Encrypt automation using the `community.crypto` collection or Certbot.

> **Note:** The seperation of networks outlined in the docker compose file is only relevant and useful if the containers were running on the same host , adding an additional layer of security between services. but since the containers are on seperate hosts , we needed to implement iptable rules to enforce that isolation! 

> **Note:** the database password should be protected inside a vault with a hidden vault password file!!


## Prerequisites

### Control Node (Your machine)
*   `ansible-core` installed.
*   SSH key-based authentication configured for the target servers.

### Target Nodes (Web & DB Servers)
*   CentOS Stream 8/9/10 or RHEL equivalent.
*   Python 3 installed (`/usr/bin/python3`).
*   Outbound internet access to pull container images.

## Project Structure

```text
.
├── inventory.ini           # Defines the Web and DB server IPs
├── playbook.yml            # Main entry point orchestrating the roles
├── requirements.yml        # Ansible Galaxy collection dependencies
└── roles/
    ├── database_server/    # Role for provisioning the DB server
    │   ├── tasks/          # Podman setup, Postgres container, Firewalld rules
    │   └── vars/           # Database credentials (Use Ansible Vault in prod!)
    └── web_server/         # Role for provisioning the Web server
        ├── files/          # Flask app code and Nginx config
        ├── templates/      # docker-compose.yml.j2 (Injects DB IP dynamically)
        └── tasks/          # Podman setup, SSL generation, Container launch
```

## Deployment Guide

### 1. Install Required Ansible Collections
This project relies on community collections for Podman and Firewalld management.
```bash
ansible-galaxy collection install -r requirements.yml
```

### 2. Configure the Inventory
Edit `inventory.ini` and replace the placeholder IP addresses with the actual IPs of your Web Server and Database Server.

```ini
[webservers]
web-server ansible_host=192.168.1.30

[databases]
db-server ansible_host=192.168.1.20
```

### 3. Run the Playbook
Execute the deployment from your control node:
```bash
ansible-playbook -i inventory.ini playbook.yml
```

##  Verification

Once the playbook finishes, verify the deployment:

1.  **Access the Application:**
    Open your browser and navigate to `https://<web-server-ip>`. (Accept the self-signed certificate warning). You should see the Flask application counter.
2.  **Verify Database Connectivity:**
    Refresh the page a few times. The counter will increment, proving the Web Server is successfully communicating with the remote Database Server over port 5432.
3.  **Verify Firewall Isolation (Security Check):**
    From a machine *other* than the Web Server (e.g., your local laptop), try to connect to the database server:
    ```bash
    nc -zv <db-server-ip> 5432
    ```
    - connection should time out because The firewall is actively blocking external access.


Y.