#!/bin/bash
# File Name: utils.sh
# Description: Utility functions for LSHC
# Author: Sourya Dutta
# Date: 2026-03-02

########################################
# Color Definitions
########################################
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

########################################
# Global Recommendation Array
########################################
RECOMMENDATIONS=()

########################################
# Print Banner
########################################
print_banner() {
    echo
    echo "========================================="
    echo "      Linux Security Health Checker      "
    echo "========================================="
    echo
}

########################################
# Print Section Header
########################################
print_header() {
    local section="$1"
    echo
    echo "-----------------------------------------"
    echo "[+] $section"
    echo "-----------------------------------------"
}

########################################
# Print Status Messages
########################################
print_success() {
    echo -e "${GREEN}[✓] $1${RESET}"
}

print_warning() {
    echo -e "${YELLOW}[!] $1${RESET}"
}

print_error() {
    echo -e "${RED}[✗] $1${RESET}"
}

########################################
# Recommendation Handling
########################################
add_recommendation() {
    RECOMMENDATIONS+=("$1")
}

print_recommendations() {
    echo
    echo "========================================="
    echo "RECOMMENDATIONS"
    echo "========================================="

    if [ ${#RECOMMENDATIONS[@]} -eq 0 ]; then
        print_success "No major security recommendations."
        return
    fi

    local i=1
    for rec in "${RECOMMENDATIONS[@]}"; do
        echo "$i. $rec"
        ((i++))
    done
}
