#!/bin/bash
# File Name: network_audit.sh
# Description: Network exposure and connection security checks (Refined)
# Author: Sourya Dutta
# Date: 2026-03-02

run_network_audit() {

    print_header "Network Security Audit"

    ########################################
    # 1. Publicly Exposed Listening Ports
    ########################################
    public_ports=$(ss -tuln 2>/dev/null | grep -E "0.0.0.0|:::") 

    if [[ -z "$public_ports" ]]; then
        print_success "No publicly exposed listening ports detected."
        add_score "NETWORK" 20
    else
        print_warning "Publicly exposed listening ports:"
        echo "$public_ports"
        add_recommendation "Restrict unnecessary services to localhost or firewall them."
        add_score "NETWORK" 10
    fi


    ########################################
    # 2. Firewall Detection (UFW / iptables / nftables)
    ########################################
    firewall_active=false

    if command -v ufw >/dev/null 2>&1; then
        if ufw status | grep -q "Status: active"; then
            firewall_active=true
        fi
    fi

    if command -v iptables >/dev/null 2>&1; then
        if iptables -L | grep -q "Chain"; then
            firewall_active=true
        fi
    fi

    if command -v nft >/dev/null 2>&1; then
        if nft list ruleset 2>/dev/null | grep -q "table"; then
            firewall_active=true
        fi
    fi

    if $firewall_active; then
        print_success "Firewall rules detected."
        add_score "NETWORK" 20
    else
        print_warning "No active firewall rules detected."
        add_recommendation "Enable UFW, iptables, or nftables to protect exposed ports."
        add_score "NETWORK" 5
    fi


    ########################################
    # 3. SSH Hardening Check
    ########################################
    if systemctl is-active ssh >/dev/null 2>&1; then

        ssh_password_auth=$(grep -Ei "^PasswordAuthentication" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}')

        if [[ "$ssh_password_auth" == "no" ]]; then
            print_success "SSH password authentication disabled."
            add_score "NETWORK" 15
        else
            print_warning "SSH password authentication enabled."
            add_recommendation "Disable SSH password authentication and use key-based login."
            add_score "NETWORK" 8
        fi

    else
        print_success "SSH service not running."
        add_score "NETWORK" 15
    fi


    ########################################
    # 4. Insecure Legacy Services
    ########################################
    insecure_ports=$(ss -tuln 2>/dev/null | grep -E ":23|:21|:512|:513|:514")

    if [[ -z "$insecure_ports" ]]; then
        print_success "No insecure legacy services (telnet/ftp/rsh) detected."
        add_score "NETWORK" 20
    else
        print_error "Insecure legacy services detected!"
        echo "$insecure_ports"
        add_recommendation "Remove telnet, FTP, and r-services. Use SSH/SFTP instead."
        add_score "NETWORK" 0
    fi


    ########################################
    # 5. Suspicious External Established Connections
    ########################################
    external_established=$(ss -tunp 2>/dev/null | grep ESTAB | grep -vE "127.0.0.1|::1")

    if [[ -z "$external_established" ]]; then
        print_success "No suspicious external established connections."
        add_score "NETWORK" 10
    else
        print_warning "Active external connections detected (review if unexpected):"
        echo "$external_established"
        add_recommendation "Verify unexpected outbound connections."
        add_score "NETWORK" 6
    fi
}
