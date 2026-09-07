#!/bin/bash
set -e
LOG_FILE="/var/log/startup-script.log"
echo "Starting user data script..." | tee -a "$LOG_FILE"
sudo apt-get update -y | tee -a "$LOG_FILE"
sudo apt-get install -y docker.io | tee -a "$LOG_FILE"
sudo systemctl start docker | tee -a "$LOG_FILE"
sudo systemctl enable docker | tee -a "$LOG_FILE"
sudo usermod -aG docker zhou | tee -a "$LOG_FILE"
sleep 5
sudo docker run -d -p 8080:80 nginx | tee -a "$LOG_FILE"
echo "User data script completed." | tee -a "$LOG_FILE"