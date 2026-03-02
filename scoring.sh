#!/bin/bash
# File Name: scoring.sh
# Description: Advanced Scoring Engine for LSHC
# Author: Sourya Dutta
# Date: 2026-03-02

########################################
# Global Score Variables
########################################

TOTAL_SCORE=0
TOTAL_MAX=0
PERCENTAGE=0

USER_SCORE=0
FILESYSTEM_SCORE=0
NETWORK_SCORE=0
SERVICE_SCORE=0
HARDENING_SCORE=0

USER_MAX=45
FILESYSTEM_MAX=58
NETWORK_MAX=65
SERVICE_MAX=70
HARDENING_MAX=20

COMPROMISED=0
RECOMMENDATIONS=()

########################################
# Initialize Scores
########################################
init_score() {
    TOTAL_SCORE=0
    TOTAL_MAX=0
    PERCENTAGE=0

    USER_SCORE=0
    FILESYSTEM_SCORE=0
    NETWORK_SCORE=0
    SERVICE_SCORE=0
    HARDENING_SCORE=0

    COMPROMISED=0
    RECOMMENDATIONS=()
}

########################################
# Add Score To Category (CAPPED)
########################################
add_score() {
    local category="$1"
    local points="$2"

    case "$category" in
        USER)
            USER_SCORE=$((USER_SCORE + points))
            [[ $USER_SCORE -gt $USER_MAX ]] && USER_SCORE=$USER_MAX
            ;;
        FILESYSTEM)
            FILESYSTEM_SCORE=$((FILESYSTEM_SCORE + points))
            [[ $FILESYSTEM_SCORE -gt $FILESYSTEM_MAX ]] && FILESYSTEM_SCORE=$FILESYSTEM_MAX
            ;;
        NETWORK)
            NETWORK_SCORE=$((NETWORK_SCORE + points))
            [[ $NETWORK_SCORE -gt $NETWORK_MAX ]] && NETWORK_SCORE=$NETWORK_MAX
            ;;
        SERVICE)
            SERVICE_SCORE=$((SERVICE_SCORE + points))
            [[ $SERVICE_SCORE -gt $SERVICE_MAX ]] && SERVICE_SCORE=$SERVICE_MAX
            ;;
        HARDENING)
            HARDENING_SCORE=$((HARDENING_SCORE + points))
            [[ $HARDENING_SCORE -gt $HARDENING_MAX ]] && HARDENING_SCORE=$HARDENING_MAX
            ;;
    esac
}

########################################
# Add Recommendation
########################################
add_recommendation() {
    RECOMMENDATIONS+=("$1")
}

########################################
# Mark System Compromised
########################################
mark_compromised() {
    COMPROMISED=1
}

########################################
# Calculate Final Risk (CORRECTED)
########################################
calculate_risk() {

    TOTAL_MAX=$((USER_MAX + FILESYSTEM_MAX + NETWORK_MAX + SERVICE_MAX + HARDENING_MAX))

    # Recalculate total from capped section values
    TOTAL_SCORE=$((USER_SCORE + FILESYSTEM_SCORE + NETWORK_SCORE + SERVICE_SCORE + HARDENING_SCORE))

    # Proper rounded percentage
    PERCENTAGE=$(awk "BEGIN {printf \"%d\", ($TOTAL_SCORE/$TOTAL_MAX)*100}")

    if [[ $COMPROMISED -eq 1 ]]; then
        RISK_LEVEL="COMPROMISED"
        return
    fi

    if [[ $PERCENTAGE -ge 85 ]]; then
        RISK_LEVEL="SECURE"
    elif [[ $PERCENTAGE -ge 65 ]]; then
        RISK_LEVEL="MODERATE RISK"
    elif [[ $PERCENTAGE -ge 40 ]]; then
        RISK_LEVEL="HIGH RISK"
    else
        RISK_LEVEL="CRITICAL RISK"
    fi
}

########################################
# Print Final Score
########################################
print_final_score() {

    calculate_risk

    echo
    echo "========================================="
    echo "              FINAL REPORT"
    echo "========================================="

    printf "User Security       : %d / %d\n" "$USER_SCORE" "$USER_MAX"
    printf "Filesystem Security : %d / %d\n" "$FILESYSTEM_SCORE" "$FILESYSTEM_MAX"
    printf "Network Security    : %d / %d\n" "$NETWORK_SCORE" "$NETWORK_MAX"
    printf "Service Security    : %d / %d\n" "$SERVICE_SCORE" "$SERVICE_MAX"
    printf "System Hardening    : %d / %d\n" "$HARDENING_SCORE" "$HARDENING_MAX"

    echo "-----------------------------------------"
    printf "FINAL SECURITY SCORE: %d / %d (%d%%)\n" "$TOTAL_SCORE" "$TOTAL_MAX" "$PERCENTAGE"
    printf "RISK LEVEL          : %s\n" "$RISK_LEVEL"
    echo "========================================="

    echo
    echo "Recommendations:"
    echo "-----------------------------------------"

    if [[ ${#RECOMMENDATIONS[@]} -eq 0 ]]; then
        echo "No major security issues detected."
    else
        for rec in "${RECOMMENDATIONS[@]}"; do
            echo "- $rec"
        done
    fi

    echo "========================================="
}
