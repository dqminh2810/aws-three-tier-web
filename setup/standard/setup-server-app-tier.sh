#!/bin/bash
set -e

SG_4_ID=$1
SUBNET_2=$2
SUBNET_5=$3
REBUILD=$4
	
# EC2 VM
if [[ $REBUILD == "--build" ]]; then
	awslocal ec2 create-key-pair \
		--key-name my-key \
		--query 'KeyMaterial' \
		--output text > my-key.pem
	chmod 400 my-key.pem
	
	## Setup EC2 Instance - AZ1/us-east-1a
	EC1_INSTANCE_ID=$(awslocal ec2 run-instances \
	    --image-id ami-df5de72bdb3b \
	    --count 1 \
	    --instance-type t3.micro \
	    --key-name my-key \
	    --security-group-ids $SG_4_ID \
	    --subnet-id $SUBNET_2 \
		--query 'Instances[0].InstanceId' \
		--output text)
	
	## Wait until ok
	awslocal ec2 wait instance-running --instance-ids $EC1_INSTANCE_ID
	EC1_PUBLIC_IP=$(awslocal ec2 describe-instances --instance-ids $EC1_INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

	## Install EC2 instance dependencies
	source ./install-server-app-tier.sh ./my-key.pem root $EC1_PUBLIC_IP

	## Create a docker image copy from EC2 instance container
	docker commit -a "admin" -m "Installed neccessary dependencies" localstack-ec2.$EC1_INSTANCE_ID localstack-ec2/ubuntu-22.04-jammy-jellyfish:ami-000001
else
	EC1_INSTANCE_ID=$(awslocal ec2 run-instances \
    --image-id ami-000001 \
    --count 1 \
    --instance-type t3.micro \
    --security-group-ids $SG_4_ID \
    --subnet-id $SUBNET_2 \
	--query 'Instances[0].InstanceId' \
	--output text)
fi




## Setup EC2 Instance - AZ2/us-east-1c
EC2_INSTANCE_ID=$(awslocal ec2 run-instances \
    --image-id ami-000001 \
    --count 1 \
    --instance-type t3.micro \
    --security-group-ids $SG_4_ID \
    --subnet-id $SUBNET_5 \
	--query 'Instances[0].InstanceId' \
	--output text)
	
## Wait until ok	
awslocal ec2 wait instance-running --instance-ids $EC2_INSTANCE_ID
EC2_PUBLIC_IP=$(awslocal ec2 describe-instances --instance-ids $EC2_INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)


# Init manually server
##this weird error showing unknow 'ssh-rsa ACCA' behind of authorized_keys
##intercepting by docker to remove it
if [[ $REBUILD != '--build' ]]; then
CONTAINER_ID_EC1=$(docker ps \
				-qaf "ancestor=localstack-ec2/ubuntu-22.04-jammy-jellyfish:ami-000001" \
				| sed -n '2p')


docker exec $CONTAINER_ID_EC1 cp root/.ssh/authorized_keys root/.ssh/tmp

docker exec $CONTAINER_ID_EC1 sed -i 's/ssh-rsa ACCA//g' root/.ssh/authorized_keys

ssh -i ./my-key.pem root@$EC1_PUBLIC_IP -p 22 'bash -s' <<'EOF'
cd ~
source ~/.bashrc
source ~/.nvm/nvm.sh
cd ~/app-tier
pm2 start index.js
EOF
fi

CONTAINER_ID_EC2=$(docker ps \
				-qaf "ancestor=localstack-ec2/ubuntu-22.04-jammy-jellyfish:ami-000001" \
				| sed -n '1p')
docker exec $CONTAINER_ID_EC2 cp root/.ssh/authorized_keys root/.ssh/tmp
docker exec $CONTAINER_ID_EC2 sed -i 's/ssh-rsa ACCA//g' root/.ssh/authorized_keys
ssh -i ./my-key.pem root@$EC2_PUBLIC_IP -p 22 'bash -s' <<'EOF'
cd ~
source ~/.bashrc
source ~/.nvm/nvm.sh
cd ~/app-tier
pm2 start index.js
EOF