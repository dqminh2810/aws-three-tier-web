#!/bin/bash
set -e

SSH_KEY_PATH=$1
REMOTE_USER=$2
REMOTE_HOST=$3

ssh -i $SSH_KEY_PATH $REMOTE_USER@$REMOTE_HOST -p 22 'bash -s' <<'EOF'
# This is the script content that runs on the remote server

apt update

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
source ~/.bashrc
source ~/.nvm/nvm.sh

nvm install 16
nvm use 16
npm install -g pm2

cd ~/
aws s3 cp s3://my-custom-bucket-xyz-2026/app-tier app-tier --recursive

cd ~/app-tier
npm install
pm2 start index.js

EOF