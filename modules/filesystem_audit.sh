#!/bin/bash
# File Name: filesystem_audit.sh
# Description: Filesystem privilege escalation checks (Refined & Accurate)
# Author: Sourya Dutta
# Date: 2026-03-02

run_filesystem_audit() {

    print_header "Filesystem Security Audit"

    ########################################
    # SAFE PATH EXCLUSIONS
    ########################################
    EXCLUDE_PATHS=(
        "/proc"
        "/sys"
        "/dev"
        "/run"
        "/snap"
        "/timeshift"
    )

    ########################################
    # 1. World-Writable Files (System Focused)
    ########################################
    world_writable_files=$(find / -xdev -type f -perm -0002 \
        ! -path "/home/*" \
        ! -path "/var/tmp/systemd-private*" \
        ! -path "/tmp/systemd-private*" \
        2>/dev/null | head -n 20)

    ww_file_count=$(echo "$world_writable_files" | grep -c "/")

    if [[ $ww_file_count -eq 0 ]]; then
        print_success "No critical world-writable system files found."
        add_score "FILESYSTEM" 15
    else
        print_warning "World-writable system files detected (up to 20 shown):"
        echo "$world_writable_files"
        add_recommendation "Remove world-writable permission from sensitive system files."
        add_score "FILESYSTEM" 5
    fi


    ########################################
    # 2. World-Writable Directories (Ignore Normal Cases)
    ########################################
    world_writable_dirs=$(find / -xdev -type d -perm -0002 \
        ! -path "/tmp" \
        ! -path "/var/tmp" \
        ! -path "/var/tmp/systemd-private*" \
        ! -path "/tmp/systemd-private*" \
        2>/dev/null | head -n 20)

    ww_dir_count=$(echo "$world_writable_dirs" | grep -c "/")

    if [[ $ww_dir_count -eq 0 ]]; then
        print_success "No abnormal world-writable directories found."
        add_score "FILESYSTEM" 10
    else
        print_warning "Potentially risky world-writable directories detected:"
        echo "$world_writable_dirs"
        add_recommendation "Restrict directory permissions or use sticky bit where appropriate."
        add_score "FILESYSTEM" 6
    fi


    ########################################
    # 3. SUID Binaries (Baseline Aware)
    ########################################
    suid_count=$(find / -xdev -type f -perm -4000 2>/dev/null | wc -l)

    if [[ $suid_count -le 120 ]]; then
        print_success "SUID binaries within expected OS range ($suid_count found)."
        add_score "FILESYSTEM" 12
    else
        print_warning "Unusually high SUID binary count detected ($suid_count found)."
        add_recommendation "Review SUID binaries and remove unnecessary privilege escalation vectors."
        add_score "FILESYSTEM" 6
    fi


    ########################################
    # 4. Strict /etc/passwd Validation
    ########################################
    owner=$(stat -c %U /etc/passwd)
    perm=$(stat -c %a /etc/passwd)

    if [[ "$owner" != "root" || "$perm" != "644" ]]; then
        print_error "/etc/passwd permissions misconfigured! (Owner: $owner | Perm: $perm)"
        add_recommendation "Set /etc/passwd ownership to root and permissions to 644."
        add_score "FILESYSTEM" 0
    else
        print_success "/etc/passwd permissions correctly configured."
        add_score "FILESYSTEM" 15
    fi


    ########################################
    # 5. Suspicious Executables in /tmp
    ########################################
    suspicious_tmp=$(find /tmp -type f -executable \
        ! -path "/tmp/systemd-private*" 2>/dev/null)

    tmp_count=$(echo "$suspicious_tmp" | grep -c "/")

    if [[ $tmp_count -eq 0 ]]; then
        print_success "No suspicious executable files found in /tmp."
        add_score "FILESYSTEM" 8
    else
        print_warning "Executable files detected in /tmp (review recommended):"
        echo "$suspicious_tmp"
        add_recommendation "Investigate unexpected executable files in /tmp."
        add_score "FILESYSTEM" 4
    fi
}
