#!/bin/bash
set -e

SSH_KEY_PATH=$1
REMOTE_USER=$2
REMOTE_HOST=$3
LB_DNS_NAME=$4

echo $LB_DNS_NAME

ssh -i $SSH_KEY_PATH $REMOTE_USER@$REMOTE_HOST -p 22 'LB_DNS_NAME='$LB_DNS_NAME' bash -s' <<'EOF'
# This is the script content that runs on the remote server
apt update
apt install -y nginx

cd ~/
aws --endpoint-url=http://localstack:4566 s3 cp s3://my-local-bucket/application-code/web-tier web-tier --recursive
source ~/.bashrc
source ~/.nvm/nvm.sh

nvm install 18
nvm use 18

cd ~/web-tier
npm install
npm run build

cd /etc/nginx
ls -al

echo $LB_DNS_NAME

rm nginx.conf
aws --endpoint-url=http://localstack:4566 s3 cp s3://my-local-bucket/application-code/nginx.conf .

REMOTE_SEARCH="\[REPLACE-WITH-INTERNAL-LB-DNS\]"
REMOTE_REPLACE="$LB_DNS_NAME"
REMOTE_TARGET="/etc/nginx/nginx.conf"

sed -i "s/$REMOTE_SEARCH/$REMOTE_REPLACE/g" "$REMOTE_TARGET"

service nginx restart
service nginx status
EOF