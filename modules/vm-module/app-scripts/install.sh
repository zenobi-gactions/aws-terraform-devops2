#!/bin/bash

# Ensure non-interactive apt to avoid hanging in automation
# export DEBIAN_FRONTEND=noninteractive

echo "🔧 Updating system..."
sudo apt update -y 
sudo apt upgrade -y

echo "🖥️ Setting hostname..."
sudo hostnamectl set-hostname jenkins-server

echo "📦 Installing base packages..."
sudo apt install -y unzip wget curl git jq gnupg lsb-release fontconfig software-properties-common \
                    openjdk-11-jdk openjdk-17-jdk nodejs npm maven apt-transport-https ca-certificates

echo "☕ Verifying Java version..."
/usr/bin/java --version

echo "🔧 Installing AWS CLI..."
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

echo "🔐 Adding Jenkins APT repo..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update -y
sudo apt install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "🛡️ Installing OWASP ZAP..."
wget -q https://github.com/zaproxy/zaproxy/releases/download/v2.16.1/ZAP_2_16_1_unix.sh
sudo chmod +x ZAP_2_16_1_unix.sh
sudo ./ZAP_2_16_1_unix.sh -q
rm ZAP_2_16_1_unix.sh

echo "🐳 Installing Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# ✅ Create docker group if it doesn't exist
sudo groupadd -f docker

# ✅ Create docker, groups and start 
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins
sudo usermod -aG docker $USER
sudo chmod 777 /var/run/docker.sock
# sudo systemctl enable docker
#sudo systemctl start docker

echo "🔍 Installing Trivy..."
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | \
  sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb \
  $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt update -y
sudo apt install -y trivy
trivy --version

echo "🧪 Installing Snyk CLI..."
wget -q https://github.com/snyk/snyk/releases/latest/download/snyk-linux
sudo chmod +x snyk-linux
sudo mv snyk-linux /usr/local/bin/snyk
snyk --version

echo "📦 Installing kubectl..."
curl -sLO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
rm kubectl

echo "📦 Installing eksctl..."
curl -sL "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin/eksctl
eksctl version

echo "📦 Installing Helm..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
sudo chmod 700 get_helm.sh
sudo ./get_helm.sh
rm get_helm.sh
helm version


echo "📁 Creating docker-compose file..."
cat <<EOT > /home/$USER/docker-compose.yaml
services:
  nexus:
    image: sonatypecommunity/nexus3
    container_name: nexus
    ports:
      - "8081:8081"
    volumes:
      - nexus-data:/nexus-data
    environment:
      - INSTALL4J_ADD_VM_PARAMS=-Xms1200m -Xmx1200m
    restart: unless-stopped

  sonarqube:
    image: sonarqube:lts-community
    container_name: sonar
    ports:
      - "9000:9000"
    volumes:
      - sonarqube-conf:/opt/sonarqube/conf
      - sonarqube-data:/opt/sonarqube/data
      - sonarqube-logs:/opt/sonarqube/logs
      - sonarqube-extensions:/opt/sonarqube/extensions
    environment:
      - SONARQUBE_JDBC_URL=jdbc:postgresql://db:5432/sonar
      - SONARQUBE_JDBC_USERNAME=sonar
      - SONARQUBE_JDBC_PASSWORD=sonar
    depends_on:
      - db
    restart: unless-stopped

  db:
    image: postgres:13
    container_name: sonarqube_db
    environment:
      - POSTGRES_USER=sonar
      - POSTGRES_PASSWORD=sonar
      - POSTGRES_DB=sonar
    volumes:
      - postgresql:/var/lib/postgresql/data
    restart: unless-stopped
  
  artifactory:
    image: releases-docker.jfrog.io/jfrog/artifactory-pro:latest
    container_name: artifactory
    ports:
      - "8083:8081"
      - "8082:8082"
    volumes:
      - $JFROG_HOME/artifactory/var/:/var/opt/jfrog/artifactory
    restart: unless-stopped

volumes:
  nexus-data:
  sonarqube-conf:
  sonarqube-data:
  sonarqube-logs:
  sonarqube-extensions:
  postgresql:
EOT

echo "🚀 Starting DevOps stack containers..."
sudo docker compose -f /home/$USER/docker-compose.yaml up -d
sleep 20
docker ps

echo "✅ CICD environment setup complete."
echo "🔗 Access Jenkins at: http://<your-server-ip>:8080"
echo "🔗 Access Nexus at: http://<your-server-ip>:8081"
echo "🔗 Access SonarQube at: http://<your-server-ip>:9000"
