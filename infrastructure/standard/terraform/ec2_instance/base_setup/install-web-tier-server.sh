#!/bin/bash
apt update
DEBIAN_FRONTEND=noninteractive apt install -y awscli nginx

export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_DEFAULT_REGION="us-east-1"
export AWS_DEFAULT_OUTPUT="json"
export AWS_ENDPOINT_URL=""

aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set default.region "$AWS_DEFAULT_REGION"
aws configure set default.output "$AWS_DEFAULT_OUTPUT"

cd ~/
aws --endpoint-url=$AWS_ENDPOINT_URL s3 cp s3://my-local-bucket/application-code/web-tier web-tier --recursive
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
aws --endpoint-url=$AWS_ENDPOINT_URL s3 cp s3://my-local-bucket/application-code/nginx.conf .

REMOTE_SEARCH="\[REPLACE-WITH-INTERNAL-LB-DNS\]"
REMOTE_REPLACE="$LB_DNS_NAME"
REMOTE_TARGET="/etc/nginx/nginx.conf"

sed -i "s/$REMOTE_SEARCH/$REMOTE_REPLACE/g" "$REMOTE_TARGET"

service nginx restart
service nginx status