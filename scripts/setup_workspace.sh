#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
STEP_DIR="$SCRIPT_DIR/steps"
declare -A step_status

run_step() {
    local step_name="$1"
    local script_path="$2"

    echo "▶ Running: $step_name"
    if bash "$script_path"; then
        step_status["$step_name"]="✅ Success"
    else
        step_status["$step_name"]="❌ Failed"
    fi
}

run_step "Install Dependencies"       "$STEP_DIR/00-install-deps.sh"
run_step "Install ROS 2"              "$STEP_DIR/01-install-ros.sh" --desktop
run_step "Fetch Drone Source"         "$STEP_DIR/02-fetch-source.sh" --full
run_step "Install Livox SDK & Driver" "$STEP_DIR/03-livox-setup.sh"
run_step "Setup Drone Server Backend" "$STEP_DIR/04-open-drone-server.sh"
run_step "Install Sims"               "$STEP_DIR/10-install-sims.sh"
run_step "Workspace Build & Systemd"  "$STEP_DIR/09-build-and-services.sh"
run_step "Frontend Setup"             "$STEP_DIR/11-frontend.sh"

echo -e "\n🧾 Setup Summary:"
for step in "${!step_status[@]}"; do
    printf "%-35s %s\n" "$step" "${step_status[$step]}"
done



