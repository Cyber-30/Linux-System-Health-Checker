#!/bin/bash
# File Name: system_info.sh
# Description: Collects basic system information
# Author: Sourya Dutta
# Date: 2026-03-02

run_system_info() {

    print_header "System Information"

    # Collect Data
    os_info=$(grep "^PRETTY_NAME" /etc/os-release | cut -d= -f2 | tr -d '"')
    kernel_version=$(uname -r)
    hostname_info=$(hostname)
    uptime_info=$(uptime -p)
    logged_in_users=$(who | awk '{print $1}' | sort | uniq | tr '\n' ' ')

    # Print Data
    print_success "Operating System : $os_info"
    print_success "Kernel Version   : $kernel_version"
    print_success "Hostname         : $hostname_info"
    print_success "Uptime           : $uptime_info"
    print_success "Logged-in Users  : $logged_in_users"
}
