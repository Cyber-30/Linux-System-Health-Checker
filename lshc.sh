#!/bin/bash
# Script Name: lshc.sh
# Description: Linux Security Health Checker
# Author: Sourya Dutta
# Date: 2026-03-02

########################################
# Base Directory Detection
########################################
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

########################################
# Root Check
########################################
if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] This tool must be run as root."
    echo "Run with: sudo ./lshc.sh"
    exit 1
fi

########################################
# Load Core Files
########################################
source "$BASE_DIR/utils.sh"
source "$BASE_DIR/scoring.sh"

########################################
# Load Modules
########################################
source "$BASE_DIR/modules/system_info.sh"
source "$BASE_DIR/modules/user_audit.sh"
source "$BASE_DIR/modules/filesystem_audit.sh"
source "$BASE_DIR/modules/network_audit.sh"
source "$BASE_DIR/modules/service_audit.sh"
source "$BASE_DIR/modules/hardening.sh"

########################################
# Execution Starts Here
########################################
print_banner
init_score

run_system_info
run_user_audit
run_filesystem_audit
run_network_audit
run_service_audit
run_hardening

print_final_score
print_recommendations
