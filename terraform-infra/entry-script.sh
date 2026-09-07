#!/bin/bash
set -e
LOG_FILE="/var/log/startup-script.log"
echo "Starting user data script..." | tee -a "$LOG_FILE"
sudo apt-get update -y | tee -a "$LOG_FILE"
sudo apt-get install -y docker.io | tee -a "$LOG_FILE"
sudo systemctl start docker | tee -a "$LOG_FILE"
sudo systemctl enable docker | tee -a "$LOG_FILE"
sudo usermod -aG docker zhou | tee -a "$LOG_FILE"