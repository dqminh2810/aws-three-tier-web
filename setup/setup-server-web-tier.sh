#!/bin/bash
set -e

SG_2_ID=$1
SUBNET_1=$2
SUBNET_4=$3
LB_DNS_NAME=$4

# EC2 VM
## Setup EC2 Instance - AZ1/us-east-1a
EC3_INSTANCE_ID=$(awslocal ec2 run-instances \
    --image-id ami-000001 \
    --count 1 \
    --instance-type t3.micro \
    --security-group-ids $SG_2_ID \
    --subnet-id $SUBNET_1 \
	--query 'Instances[0].InstanceId' \
	--output text)

awslocal ec2 wait instance-running --instance-ids $EC3_INSTANCE_ID
EC3_PUBLIC_IP=$(awslocal ec2 describe-instances --instance-ids $EC3_INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

## Setup EC2 Instance - AZ2/us-east-1c
EC4_INSTANCE_ID=$(awslocal ec2 run-instances \
    --image-id ami-000001 \
    --count 1 \
    --instance-type t3.micro \
    --security-group-ids $SG_2_ID \
    --subnet-id $SUBNET_4 \
	--query 'Instances[0].InstanceId' \
	--output text)
	
awslocal ec2 wait instance-running --instance-ids $EC4_INSTANCE_ID
EC4_PUBLIC_IP=$(awslocal ec2 describe-instances --instance-ids $EC4_INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)


# Debug ssh keys
##this weird error showing unknow 'ssh-rsa ACCA' behind of authorized_keys
##intercepting by docker to remove it
CONTAINER_ID_EC3=$(docker ps -qaf \
					"ancestor=localstack-ec2/ubuntu-22.04-jammy-jellyfish:ami-000001" \
					| sed -n '2p')
CONTAINER_ID_EC4=$(docker ps -qaf \
					"ancestor=localstack-ec2/ubuntu-22.04-jammy-jellyfish:ami-000001" \
					| sed -n '1p')

docker exec $CONTAINER_ID_EC3 cp root/.ssh/authorized_keys root/.ssh/tmp
docker exec $CONTAINER_ID_EC4 cp root/.ssh/authorized_keys root/.ssh/tmp

docker exec $CONTAINER_ID_EC3 sed -i 's/ssh-rsa ACCA//g' root/.ssh/authorized_keys
docker exec $CONTAINER_ID_EC4 sed -i 's/ssh-rsa ACCA//g' root/.ssh/authorized_keys


# Install EC2 instance dependencies
source ./install-server-web-tier.sh ./my-key.pem root $EC3_PUBLIC_IP $LB_DNS_NAME
source ./install-server-web-tier.sh ./my-key.pem root $EC4_PUBLIC_IP $LB_DNS_NAME

# Create a docker image copy from EC2 instance container
#docker commit -a "admin" -m "Installed neccessary dependencies" localstack-ec2.$EC3_INSTANCE_ID localstack-ec2/ubuntu-22.04-jammy-jellyfish:ami-000002