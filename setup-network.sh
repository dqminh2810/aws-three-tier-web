#!/bin/bash
set -e

##VPC
VPC_ID=$(awslocal ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.{VpcId:VpcId}' --output text)
awslocal ec2 create-tags --resources $VPC_ID --tags Key=name,Value=localVPC


##SUBNET
SUBNET_1=$(awslocal ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.0.0/24 --availability-zone us-east-1a --query 'Subnet.{SubnetId:SubnetId}' --output text)
awslocal ec2 create-tags --resources $SUBNET_1 --tags Key=name,Value=public-web-subnet-AZ-1

SUBNET_2=$(awslocal ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.10.0/24 --availability-zone us-east-1a --query 'Subnet.{SubnetId:SubnetId}' --output text)
awslocal ec2 create-tags --resources $SUBNET_2 --tags Key=name,Value=private-app-subnet-AZ-1

SUBNET_3=$(awslocal ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.20.0/24 --availability-zone us-east-1a --query 'Subnet.{SubnetId:SubnetId}' --output text)
awslocal ec2 create-tags --resources $SUBNET_3 --tags Key=name,Value=private-db-subnet-AZ-1

SUBNET_4=$(awslocal ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.30.0/24 --availability-zone us-east-1c --query 'Subnet.{SubnetId:SubnetId}' --output text)
awslocal ec2 create-tags --resources $SUBNET_4 --tags Key=name,Value=public-web-subnet-AZ-2

SUBNET_5=$(awslocal ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.40.0/24 --availability-zone us-east-1c --query 'Subnet.{SubnetId:SubnetId}' --output text)
awslocal ec2 create-tags --resources $SUBNET_5 --tags Key=name,Value=private-app-subnet-AZ-2

SUBNET_6=$(awslocal ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.50.0/24 --availability-zone us-east-1c --query 'Subnet.{SubnetId:SubnetId}' --output text)
awslocal ec2 create-tags --resources $SUBNET_6 --tags Key=name,Value=private-db-subnet-AZ-2


## INTERNET GATEWAY
IGW_ID=$(awslocal ec2 create-internet-gateway | jq -r '.InternetGateway.InternetGatewayId')
awslocal ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID
awslocal ec2 create-tags --resources $IGW_ID --tags Key=name,Value=three-tier-igw


## NAT GATEWAY
EIP_1_ID=$(awslocal ec2 allocate-address --domain vpc | jq -r '.AllocationId')
NGW_1_ID=$(awslocal ec2 create-nat-gateway --subnet-id $SUBNET_1 --allocation-id $EIP_1_ID --query 'NatGateway.NatGatewayId' --output text)
awslocal ec2 create-tags --resources $NGW_1_ID --tags Key=name,Value=three-tier-ngw-1

EIP_2_ID=$(awslocal ec2 allocate-address --domain vpc | jq -r '.AllocationId')
NGW_2_ID=$(awslocal ec2 create-nat-gateway --subnet-id $SUBNET_4 --allocation-id $EIP_2_ID --query 'NatGateway.NatGatewayId' --output text)
awslocal ec2 create-tags --resources $NGW_2_ID --tags Key=name,Value=three-tier-ngw-2


## ROUTE TABLE
#### PUBLIC SUBNET
PUBLIC_RT_ID=$(awslocal ec2 create-route-table --vpc-id $VPC_ID --endpoint-url=http://localhost:4566 --query 'RouteTable.RouteTableId' --output text)
awslocal ec2 create-tags --resources $PUBLIC_RT_ID --tags Key=name,Value=three-tier-ngw-2
awslocal ec2 create-route --route-table-id $PUBLIC_RT_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID --endpoint-url=http://localhost:4566
awslocal ec2 associate-route-table --route-table-id $PUBLIC_RT_ID --subnet-id $SUBNET_1 --endpoint-url=http://localhost:4566
awslocal ec2 associate-route-table --route-table-id $PUBLIC_RT_ID --subnet-id $SUBNET_4 --endpoint-url=http://localhost:4566

#### PRIVATE SUBNET
PRIVATE_RT_1_ID=$(awslocal ec2 create-route-table --vpc-id $VPC_ID --endpoint-url=http://localhost:4566 --query 'RouteTable.RouteTableId' --output text)
awslocal ec2 create-route --route-table-id $PRIVATE_RT_1_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $NGW_1_ID --endpoint-url=http://localhost:4566
awslocal ec2 associate-route-table --route-table-id $PRIVATE_RT_1_ID --subnet-id $SUBNET_2 --endpoint-url=http://localhost:4566
awslocal ec2 associate-route-table --route-table-id $PRIVATE_RT_1_ID --subnet-id $SUBNET_5 --endpoint-url=http://localhost:4566

PRIVATE_RT_2_ID=$(awslocal ec2 create-route-table --vpc-id $VPC_ID --endpoint-url=http://localhost:4566 --query 'RouteTable.RouteTableId' --output text)
awslocal ec2 create-route --route-table-id $PRIVATE_RT_2_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $NGW_2_ID --endpoint-url=http://localhost:4566
awslocal ec2 associate-route-table --route-table-id $PRIVATE_RT_2_ID --subnet-id $SUBNET_3 --endpoint-url=http://localhost:4566
awslocal ec2 associate-route-table --route-table-id $PRIVATE_RT_2_ID --subnet-id $SUBNET_6 --endpoint-url=http://localhost:4566


## SECURITY GROUP
#### External ALB
SG_1_ID=$(awslocal ec2 create-security-group --group-name external-lb-sg --description "SG for the external load balancer" --vpc-id $VPC_ID --query 'GroupId' --output text)
awslocal ec2 authorize-security-group-ingress \
    --group-id $SG_1_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

#### Web Tier
SG_2_ID=$(awslocal ec2 create-security-group --group-name web-tier-instance-sg --description "SG for the web tier" --vpc-id $VPC_ID --query 'GroupId' --output text)
awslocal ec2 authorize-security-group-ingress \
    --group-id $SG_2_ID \
    --protocol tcp \
    --port 80 \
	--source-group $SG_1_ID

#### Internal ALB
SG_3_ID=$(awslocal ec2 create-security-group --group-name internal-lb-sg --description "SG for the internal load balancer" --vpc-id $VPC_ID --query 'GroupId' --output text)
awslocal ec2 authorize-security-group-ingress \
    --group-id $SG_3_ID \
    --protocol tcp \
    --port 80 \
	--source-group $SG_2_ID
	
#### App Tier
SG_4_ID=$(awslocal ec2 create-security-group --group-name app-tier-instance-sg --description "SG for the app tier" --vpc-id $VPC_ID --query 'GroupId' --output text)
awslocal ec2 authorize-security-group-ingress \
    --group-id $SG_4_ID \
    --protocol tcp \
    --port 22 \
	--source-group $SG_3_ID
awslocal ec2 authorize-security-group-ingress \
    --group-id $SG_4_ID \
    --protocol tcp \
    --port 4000 \
	--source-group $SG_3_ID
	
#### DB Tier
SG_5_ID=$(awslocal ec2 create-security-group --group-name db-tier-instance-sg --description "SG for the db tier" --vpc-id $VPC_ID --query 'GroupId' --output text)
awslocal ec2 authorize-security-group-ingress \
    --group-id $SG_5_ID \
    --protocol tcp \
    --port 4510 \
	--source-group $SG_4_ID

