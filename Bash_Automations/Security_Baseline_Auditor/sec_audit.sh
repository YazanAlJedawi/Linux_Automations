#!/bin/bash
# Author: Yazan AlJedawi , https://github.com/YazanAlJedawi
# Created: 17.8.2026
# Modified: Not yet!
# Description:
# A lightweight Bash script that checks a RHEL/CentOS system against five essential security best practices  
# It produces a clear {Pass/Fail} report and **does not** change any settings automatically.


RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' 


print_result() {
	check_name="$1"
	status="$2"  
	if [[ "$status" == "PASS" ]]; then
		echo -e "${GREEN}[PASS]${NC} $check_name"
	else
		echo -e "${RED}[FAIL]${NC} $check_name"
	fi
}

if [[ $UID -ne 0 ]]; then
	echo "[*] This script needs root privileges to run !"
	exit 1
fi

check_root_ssh() {
	if grep -qE "^PermitRootLogin\s+no" /etc/ssh/sshd_config 2>/dev/null; then
		print_result "Root SSH login is disabled" "PASS"
		return 0
	else
		print_result "Root SSH login is NOT disabled (or it can be commented, better to check!)" "FAIL"
		return 1
	fi
}

check_writable_etc() {
	
	sudo find /etc -type f -perm -0002 > etc_writable_by_others.txt
	
	if [ ! -s etc_writable_by_others.txt ]; then
		print_result "No files in /etc are writable by others" "PASS"
		return 0
	else
		print_result "Found at least one file in /etc writable by others, use can find them in the etc_writable_by_others.txt file" "FAIL"
		return 1
	fi
}

check_firewall() {
	if systemctl is-active --quiet firewalld 2>/dev/null; then
		print_result "Firewalld is running" "PASS"
		return 0
	else
		print_result "Firewalld is NOT running" "FAIL"
		return 1
	fi
}


check_password_expiry() {
	local max_days
	
	max_days=$(grep -E "^PASS_MAX_DAYS\s+[0-9]+" /etc/login.defs 2>/dev/null | awk '{print $2}')
	if [[ -z "$max_days" ]]; then
		print_result "PASS_MAX_DAYS not set in /etc/login.defs" "FAIL"
		return 1
	elif [[ "$max_days" -le 90 && "$max_days" -gt 0 ]]; then
		print_result "Password expiration is set to $max_days days" "PASS"
		return 0
	else
		print_result "Password expiration is not properly set (max $max_days days, should be <=90)" "FAIL"
		return 1
	fi
}



check_selinux() {
	local mode
	mode=$(getenforce 2>/dev/null)
	if [[ "$mode" == "Enforcing" ]]; then
		print_result "SELinux is Enforcing" "PASS"
		return 0
	else
		print_result "SELinux is $mode and not Enforcing" "FAIL"
		return 1
	fi
}


echo " 
====================================
RHEL Security Audit Report
====================================
"

check_root_ssh
check_writable_etc
check_firewall
check_password_expiry
check_selinux


exit 0

