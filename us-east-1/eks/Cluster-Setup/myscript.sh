#!/bin/bash

# Install AWS CLI on Bastion Host

sudo apt update -y
sudo apt install -y unzip curl
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install

# Install kubectl on Bastion Host

sudo curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.7/2024-12-12/bin/linux/amd64/kubectl && sudo chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/kubectl
