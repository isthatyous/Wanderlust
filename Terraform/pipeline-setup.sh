#!/bin/bash

# Update Machine
sudo apt update && sudo apt upgrade -y


# Install Jenkins
sudo apt install -y fontconfig openjdk-21-jre

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins 


# start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins


# Install Docker
sudo apt-get install docker.io -y
sudo systemctl enable docker

# Added user to docker grp and refresh group
sudo usermod -aG docker ubuntu && newgrp docker
sudo usermod -aG docker jenkins

# Restart services
sudo systemctl restart docker
sudo systemctl restart jenkins


# Install sonarQube Server
   docker run -d --name sonarqube \
    -p 9000:9000 \
    -v sonarqube_data:/opt/sonarqube/data \
    -v sonarqube_logs:/opt/sonarqube/logs \
    -v sonarqube_extensions:/opt/sonarqube/extensions \
    -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
    sonarqube:community



# OWASP Installation
cd /opt
wget https://github.com/jeremylong/DependencyCheck/releases/download/v12.1.9/dependency-check-12.1.9-release.zip
unzip dependency-check-12.1.9-release.zip
mv dependency-check /usr/local/bin/dependency-check

export PATH=$PATH:/usr/local/bin/dependency-check/bin

dependency-check.sh --update
