#!/bin/bash
set -e
LOG_FILE="/var/log/startup-script.log"
sudo apt-get update -y | tee -a "$LOG_FILE"
sudo apt-get install -y docker.io | tee -a "$LOG_FILE"
sudo systemctl start docker | tee -a "$LOG_FILE"
sudo systemctl enable docker | tee -a "$LOG_FILE"
sudo usermod -aG docker zhou | tee -a "$LOG_FILE"
sleep 10
echo "${docker_pass}" | docker login -u "${docker_user}" --password-stdin | tee -a "$LOG_FILE"
docker pull zhoupan970810/sudoku-game:latest | tee -a "$LOG_FILE"
docker stop sudoku-app 2>/dev/null || true | tee -a "$LOG_FILE"
docker rm sudoku-app 2>/dev/null || true | tee -a "$LOG_FILE"
docker run -d -p 5000:5000 --name sudoku-app --restart unless-stopped zhoupan970810/sudoku-game:latest | tee -a "$LOG_FILE"
