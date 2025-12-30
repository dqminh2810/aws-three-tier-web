#!/bin/bash

set -e

rm -f my-key.pem

# Setup AWS network
source ./setup-network.sh

# Setup AWS DB & EC2 Instance - AZ1/us-east-1a
source ./setup-server.sh $SG_4_ID $SG_5_ID $SUBNET_2 $SUBNET_3 $SUBNET_5 $SUBNET_6

# Install EC2 instance dependencies
source ./install-server.sh ./my-key.pem root $EC1_PUBLIC_IP

# Create a docker image copy from EC2 instance container
docker commit -a "admin" -m "Installed neccessary dependencies" localstack-ec2.$EC1_INSTANCE_ID localstack-ec2/ubuntu-22.04-jammy-jellyfish:ami-000001 

# Setup EC2 Instance - AZ2/us-east-1c
EC2_INSTANCE_ID=$(awslocal ec2 run-instances \
    --image-id ami-000001 \
    --count 1 \
    --instance-type t3.micro \
    --key-name my-key \
    --security-group-ids $SG_4_ID \
    --subnet-id $SUBNET_5 \
	--query 'Instances[0].InstanceId' \
	--output text)
	
awslocal ec2 wait instance-running --instance-ids $EC2_INSTANCE_ID

EC2_PUBLIC_IP=$(awslocal ec2 describe-instances --instance-ids $EC2_INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

# Init DB
psql -d testdb -U admin -p 4510 -h localhost -f initDB.sql -W


#### OUTPUT
cat <<EOF > output.txt
	$NGW_ID "*******VPC*******"
	$NGW_ID "VPC_ID = $VPC_ID"
	$NGW_ID '\n'

	$NGW_ID "*******SUBNET*******"
	$NGW_ID "SUBNET_1 = $SUBNET_1"
	$NGW_ID "SUBNET_2 = $SUBNET_2"
	$NGW_ID "SUBNET_3 = $SUBNET_3"
	$NGW_ID "SUBNET_4 = $SUBNET_4"
	$NGW_ID "SUBNET_5 = $SUBNET_5"
	$NGW_ID "SUBNET_6 = $SUBNET_6"
	$NGW_ID '\n'

	$NGW_ID "*******GATEWAY*******"
	$NGW_ID "IGW_ID = $IGW_ID"
	$NGW_ID "EIP_1_ID = $EIP_1_ID"
	$NGW_ID "NGW_1_ID = $NGW_1_ID"
	$NGW_ID "EIP_2_ID = $EIP_2_ID"
	$NGW_ID "NGW_2_ID = $NGW_2_ID"
	$NGW_ID '\n'

	$NGW_ID "*******ROUTE TABLE*******"
	$NGW_ID "PUBLIC_RT_ID = $PUBLIC_RT_ID"
	$NGW_ID "PRIVATE_RT_1_ID = $PRIVATE_RT_1_ID"
	$NGW_ID "PRIVATE_RT_2_ID = $PRIVATE_RT_2_ID"
	$NGW_ID '\n'

	$NGW_ID "*******SECURITY GROUP*******"
	$NGW_ID "SG_1_ID = $SG_1_ID"
	$NGW_ID "SG_2_ID = $SG_2_ID"
	$NGW_ID "SG_3_ID = $SG_3_ID"
	$NGW_ID "SG_4_ID = $SG_4_ID"
	$NGW_ID "SG_5_ID = $SG_5_ID"
	$NGW_ID '\n'

	$NGW_ID "*******EC2 VM*******"
	$NGW_ID "EC1_INSTANCE_ID = $EC1_INSTANCE_ID"
	$NGW_ID "EC2_INSTANCE_ID = $EC2_INSTANCE_ID"
	$NGW_ID "EC1_PUBLIC_IP = $EC1_PUBLIC_IP"
	$NGW_ID "EC2_PUBLIC_IP = $EC2_PUBLIC_IP"
EOF