#!/bin/bash
# File Name: service_audit.sh
# Description: Service and persistence security audit (Refined)
# Author: Sourya Dutta
# Date: 2026-03-02

run_service_audit() {

    print_header "Service & Persistence Security Audit"

    ########################################
    # 1. Network-Exposed Services (REAL RISK)
    ########################################
    exposed_services=$(ss -tuln 2>/dev/null | grep LISTEN)

    public_exposed=$(ss -tuln 2>/dev/null | grep -E "0.0.0.0|:::") 

    if [[ -z "$public_exposed" ]]; then
        print_success "No publicly exposed listening services detected."
        add_score "SERVICE" 20
    else
        print_warning "Publicly exposed listening ports detected:"
        echo "$public_exposed"
        add_recommendation "Restrict unnecessary services to localhost or firewall them."
        add_score "SERVICE" 10
    fi


    ########################################
    # 2. Suspicious Service Names
    ########################################
    suspicious_patterns="xmrig|mining|crypto|backdoor|meterpreter|nc|netcat"
    suspicious_services=$(systemctl list-units --type=service --state=running 2>/dev/null | grep -Ei "$suspicious_patterns")

    if [[ -z "$suspicious_services" ]]; then
        print_success "No suspicious running service names detected."
        add_score "SERVICE" 15
    else
        print_error "Suspicious running services detected!"
        echo "$suspicious_services"
        add_recommendation "Investigate unknown or suspicious services immediately."
        add_score "SERVICE" 0
    fi


    ########################################
    # 3. Services Running From Unusual Paths
    ########################################
    unusual_exec=$(ps -eo comm,args | grep -E "/tmp|/dev/shm|/var/tmp" | grep -v grep)

    if [[ -z "$unusual_exec" ]]; then
        print_success "No services running from temporary directories."
        add_score "SERVICE" 15
    else
        print_error "Services executing from temporary directories detected!"
        echo "$unusual_exec"
        add_recommendation "Investigate processes running from /tmp, /dev/shm, or /var/tmp."
        add_score "SERVICE" 5
    fi


    ########################################
    # 4. Failed Services
    ########################################
    failed_services=$(systemctl --failed --no-legend 2>/dev/null)

    if [[ -z "$failed_services" ]]; then
        print_success "No failed services detected."
        add_score "SERVICE" 10
    else
        print_warning "Failed services detected:"
        echo "$failed_services"
        add_recommendation "Investigate failed services for stability or compromise."
        add_score "SERVICE" 5
    fi


    ########################################
    # 5. Insecure Legacy Network Services
    ########################################
    insecure_ports=$(ss -tuln 2>/dev/null | grep -E ":23|:21|:512|:513|:514")

    if [[ -z "$insecure_ports" ]]; then
        print_success "No insecure legacy services (telnet/ftp/rsh) detected."
        add_score "SERVICE" 20
    else
        print_error "Insecure legacy network services detected!"
        echo "$insecure_ports"
        add_recommendation "Remove telnet, FTP, and r-services. Use SSH/SFTP instead."
        add_score "SERVICE" 0
    fi


    ########################################
    # 6. User-Level Cron Persistence
    ########################################
    user_cron=$(for user in $(cut -f1 -d: /etc/passwd); do crontab -u $user -l 2>/dev/null; done)

    if [[ -z "$user_cron" ]]; then
        print_success "No user-level cron jobs detected."
        add_score "SERVICE" 10
    else
        print_warning "User-level cron jobs detected:"
        echo "$user_cron"
        add_recommendation "Review user cron jobs for persistence mechanisms."
        add_score "SERVICE" 6
    fi
}
