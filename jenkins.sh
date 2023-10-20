#!bin/bash

echo "___________________Installing Jenkins______________________"

sudo apt-get update

#install python and pip 
sudo apt install python3-pip

sudo apt update

#install java
sudo apt install fontconfig openjdk-17-jre

#download jenkins debian package
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update

sudo apt-get install jenkins

sudo systemctl start jenkins.service

sudo cat /var/lib/jenkins/secrets/intitialAdminPassword

sudo apt-get update