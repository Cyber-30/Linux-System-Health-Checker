#!/bin/bash
# File Name: user_audit.sh
# Description: User and privilege security checks (Refined)
# Author: Sourya Dutta
# Date: 2026-03-02

run_user_audit() {

    print_header "User Security Audit"

    ########################################
    # 1. UID 0 Users
    ########################################
    uid_zero_users=$(awk -F: '($3 == 0) { print $1 }' /etc/passwd)

    if [[ "$uid_zero_users" == "root" ]]; then
        print_success "Only root has UID 0."
        add_score "USER" 15
    else
        print_error "Unauthorized UID 0 users detected:"
        echo "$uid_zero_users"
        add_recommendation "Remove or demote unauthorized UID 0 accounts."
        add_score "USER" 0
    fi


    ########################################
    # 2. Sudo Privilege Review
    ########################################
    sudo_users=$(getent group sudo | cut -d: -f4)
    sudo_count=$(echo "$sudo_users" | tr ',' '\n' | grep -c .)

    if [[ -z "$sudo_users" ]]; then
        print_success "No users in sudo group."
        add_score "USER" 10
    elif [[ $sudo_count -le 2 ]]; then
        print_success "Limited sudo users detected ($sudo_users)."
        add_score "USER" 10
    else
        print_warning "Multiple sudo users detected: $sudo_users"
        add_recommendation "Limit sudo access to necessary administrative accounts only."
        add_score "USER" 5
    fi


    ########################################
    # 3. SSH Root Login
    ########################################
    if systemctl is-active ssh >/dev/null 2>&1; then

        ssh_root_login=$(grep -Ei "^PermitRootLogin" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}')

        if [[ "$ssh_root_login" == "no" ]]; then
            print_success "SSH root login disabled."
            add_score "USER" 15
        else
            print_warning "SSH root login enabled or not explicitly disabled."
            add_recommendation "Set 'PermitRootLogin no' in sshd_config."
            add_score "USER" 7
        fi

    else
        print_success "SSH service not active."
        add_score "USER" 10
    fi


    ########################################
    # 4. Passwordless or Unlocked Accounts
    ########################################
    unlocked_accounts=$(awk -F: '($2 == "" || $2 == "!" ) { print $1 }' /etc/shadow 2>/dev/null)

    if [[ -z "$unlocked_accounts" ]]; then
        print_success "No accounts with empty or unlocked passwords."
        add_score "USER" 15
    else
        print_warning "Accounts with potentially insecure password fields:"
        echo "$unlocked_accounts"
        add_recommendation "Lock unused accounts and ensure password fields are secured."
        add_score "USER" 5
    fi


    ########################################
    # 5. Home Directory Permissions
    ########################################
    insecure_home_dirs=()

    while IFS=: read -r user _ uid _ _ home _; do
        if [[ $uid -ge 1000 && -d "$home" ]]; then
            perms=$(stat -c "%a" "$home")
            other_perm=${perms: -1}
            if [[ $other_perm -gt 0 ]]; then
                insecure_home_dirs+=("$user")
            fi
        fi
    done < /etc/passwd

    if [[ ${#insecure_home_dirs[@]} -eq 0 ]]; then
        print_success "Home directory permissions properly restricted."
        add_score "USER" 10
    else
        print_warning "Home directories accessible by others:"
        echo "${insecure_home_dirs[*]}"
        add_recommendation "Restrict home directory permissions (chmod 750 or 700)."
        add_score "USER" 5
    fi
}
