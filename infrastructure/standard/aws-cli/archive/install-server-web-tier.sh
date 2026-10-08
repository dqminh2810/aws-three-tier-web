#!/bin/bash
set -e

SSH_KEY_PATH=$1
REMOTE_USER=$2
REMOTE_HOST=$3
LB_DNS_NAME=$4

echo $LB_DNS_NAME

# ssh -i $SSH_KEY_PATH $REMOTE_USER@$REMOTE_HOST -p 22 'LB_DNS_NAME='$LB_DNS_NAME' bash -s' <<'EOF'
ssh -i $SSH_KEY_PATH $REMOTE_USER@$REMOTE_HOST -p 22 bash -s <<'EOF'

# This is the script content that runs on the remote serveraws
sudo apt update -y
sudo apt install -y nginx curl

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm --versionsource ~/.bashrc
nvm install 18
nvm use 18

cd ~/
aws s3 cp s3://my-custom-bucket-xyz-2026/web-tier/ web-tier --recursive

cd ~/web-tier
npm install
npm run build

cd /etc/nginx
ls -al

#echo $LB_DNS_NAME

sudo rm nginx.conf
sudo aws s3 cp s3://my-custom-bucket-xyz-2026/web-tier/nginx.conf .

# REMOTE_SEARCH="\[REPLACE-WITH-INTERNAL-LB-DNS\]"
# REMOTE_REPLACE="$LB_DNS_NAME"
# REMOTE_TARGET="/etc/nginx/nginx.conf"

# sed -i "s/$REMOTE_SEARCH/$REMOTE_REPLACE/g" "$REMOTE_TARGET"

sudo systemctl start nginx
sudo systemctl status nginx
EOF