#!/bin/bash

echo "----------UPDATE SYSTEM----------"
sudo apt update -y
sudo apt upgrade -y
sudo apt dist-upgrade -y
sudo apt autoremove -y

echo "----------INSTALL UTILS----------"
sudo apt install htop curl wget -y

echo "----------DISABLE SWAP----------"
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo update-rc.d dphys-swapfile remove
sudo apt purge dphys-swapfile -y

echo "----------INSTALL DOCKER----------"
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh -y
sudo usermod -aG docker $USER && newgrp docker
sudo systemctl daemon-reload && sudo systemctl enable docker && sudo systemctl restart docker
sudo apt install docker-compose

echo "----------INSTALL MINIKUBE----------"
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-arm64
sudo install minikube-linux-arm64 /usr/local/bin/minikube
minikube start
minikube addons enable ingress
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
sudo apt install bash-completion
echo 'source <(kubectl completion bash)' >>~/.bashrc

echo "----------CREATE MINIKUBE DAEMON----------"
sudo touch /etc/systemd/system/minikube.service
sudo echo "[Unit]\nDescription=Runs minikube on startup\nAfter=docker.service\n[Service]\nExecStart=/usr/local/bin/minikube start\nExecStop=/usr/local/bin/minikube stop\nType=oneshot\nRemainAfterExit=yes\nUser=$USER\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/minikube.service
sudo systemctl daemon-reload 
sudo service minikube start
sudo systemctl enable minikube

echo "----------REBOOT----------"
sudo reboot