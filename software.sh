#!bin/bash

sudo apt update

#download java runtime environment for jenkins agent
sudo apt install default-jre


#installs ability to install, update, remove, and manage packages/ y for yes/ able to use apt for adding python dependencies
sudo apt install -y software-properties-common

#downloads updated versions of python 
sudo add-apt-repository -y ppa:deadsnakes/ppa

#install python version
sudo apt install -y python3.7

#install python virtual environment
sudo apt install -y python3.7-venv

sudo apt upgrade