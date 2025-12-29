#!/bin/bash
set -e

SSH_KEY_PATH=$1
REMOTE_USER=$2
REMOTE_HOST=$3

ssh -i $SSH_KEY_PATH $REMOTE_USER@$REMOTE_HOST -p 22 'bash -s' <<'EOF'
# This is the script content that runs on the remote server

apt-get update
apt-get install -y unzip

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws

export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_DEFAULT_REGION="us-east-1"
export AWS_DEFAULT_OUTPUT="json"

aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set default.region "$AWS_DEFAULT_REGION"
aws configure set default.output "AWS_DEFAULT_OUTPUT"

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
source ~/.bashrc
source ~/.nvm/nvm.sh

nvm install 16
nvm use 16
npm install -g pm2

cd ~/
aws --endpoint-url=http://localstack:4566 s3 cp s3://my-local-bucket/application-code/app-tier app-tier --recursive

cd ~/app-tier
npm install
pm2 start index.js

EOF
