#!/bin/bash
# File Name: hardening.sh
# Description: Interactive system hardening module (Refined)
# Author: Sourya Dutta
# Date: 2026-03-02

ask_and_apply() {
    read -p "$1 (y/n): " choice
    if [[ "$choice" == "y" ]]; then
        eval "$2"
        print_success "$3"
    else
        print_warning "Skipped: $3"
    fi
}

run_hardening() {

    print_header "Interactive System Hardening"

    ########################################
    # 1. Disable SSH Root Login
    ########################################
    if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config 2>/dev/null; then
        ask_and_apply \
        "Disable SSH root login?" \
        "sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config && systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null" \
        "SSH root login disabled."
    else
        print_success "SSH root login already secure."
    fi

    ########################################
    # 2. Disable SSH Password Authentication
    ########################################
    if grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config 2>/dev/null; then
        ask_and_apply \
        "Disable SSH password authentication? (Ensure SSH keys are configured!)" \
        "sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null" \
        "SSH password authentication disabled."
    else
        print_success "SSH password authentication already secure."
    fi

    ########################################
    # 3. Secure /etc/passwd Permissions
    ########################################
    ask_and_apply \
    "Fix /etc/passwd permissions to 644 and root ownership?" \
    "chmod 644 /etc/passwd && chown root:root /etc/passwd" \
    "/etc/passwd permissions secured."

    ########################################
    # 4. Fix Home Directory Permissions
    ########################################
    ask_and_apply \
    "Set all user home directories to 750? (May affect shared setups)" \
    "while IFS=: read -r user _ uid _ _ home _; do
        if [[ \$uid -ge 1000 && -d \"\$home\" ]]; then
            chmod 750 \"\$home\"
        fi
     done < /etc/passwd" \
    "Home directory permissions adjusted."

    ########################################
    # 5. Remove World-Writable Files in /home and /tmp
    ########################################
    ask_and_apply \
    "Remove world-writable permission from files in /home and /tmp?" \
    "find /home /tmp -type f -perm -0002 -exec chmod o-w {} \; 2>/dev/null" \
    "World-writable permissions removed from /home and /tmp."

    ########################################
    # 6. Enable Firewall (UFW)
    ########################################
    if command -v ufw >/dev/null 2>&1; then
        status=$(ufw status 2>/dev/null | grep -i "Status: active")
        if [[ -z "$status" ]]; then
            ask_and_apply \
            "Enable UFW firewall?" \
            "ufw --force enable" \
            "Firewall enabled."
        else
            print_success "Firewall already active."
        fi
    else
        print_warning "UFW not installed. Skipping firewall setup."
    fi

    ########################################
    # 7. Disable Telnet if Installed
    ########################################
    if systemctl list-unit-files 2>/dev/null | grep -qE 'telnet|telnet.socket'; then
        ask_and_apply \
        "Disable Telnet service?" \
        "systemctl disable telnet 2>/dev/null && systemctl stop telnet 2>/dev/null || systemctl disable telnet.socket 2>/dev/null && systemctl stop telnet.socket 2>/dev/null" \
        "Telnet service disabled."
    else
        print_success "Telnet not installed or already disabled."
    fi

    print_success "Interactive hardening session completed."
}
