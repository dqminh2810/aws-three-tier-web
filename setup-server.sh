#!/bin/bash
set -e

SG_4_ID=$1
SG_5_ID=$2
SUBNET_2=$3
SUBNET_3=$4
SUBNET_5=$5
SUBNET_6=$6

## RDS
awslocal rds create-db-subnet-group \
    --db-subnet-group-name my-subnet-group \
    --db-subnet-group-description "My LocalStack DB Subnet Group" \
    --subnet-ids $SUBNET_3 $SUBNET_6

#### RDS - Cluster 
awslocal rds create-db-cluster \
	--db-cluster-identifier my-db-cluster \
	--engine aurora-postgresql \
	--database-name testdb \
	--master-username admin \
	--master-user-password password

#### RDS - Instance - AZ1 / us-east-1a
awslocal rds create-db-instance \
    --db-instance-identifier my-db-instance-az1 \
	--db-cluster-identifier my-db-cluster \
	--port 4510 \
    --engine aurora-postgresql \
    --db-instance-class db.r5.large \
	--availability-zone us-east-1a \
    --db-subnet-group-name my-subnet-group \
    --vpc-security-group-ids $SG_5_ID \
    --publicly-accessible

#### RDS - Instance - AZ2 / us-east-1c
awslocal rds create-db-instance \
    --db-instance-identifier my-db-instance-az2 \
	--db-cluster-identifier my-db-cluster \
	--port 4510 \
    --engine aurora-postgresql \
    --db-instance-class db.r5.large \
	--availability-zone us-east-1c \
    --db-subnet-group-name my-subnet-group \
    --vpc-security-group-ids $SG_5_ID \
    --publicly-accessible

	
## EC2 VM
awslocal ec2 create-key-pair \
	--key-name my-key \
	--query 'KeyMaterial' \
	--output text > my-key.pem

chmod 400 my-key.pem

#### EC2 Instance - AZ1 / us-east-1a
EC1_INSTANCE_ID=$(awslocal ec2 run-instances \
    --image-id ami-df5de72bdb3b \
    --count 1 \
    --instance-type t3.micro \
    --key-name my-key \
    --security-group-ids $SG_4_ID \
    --subnet-id $SUBNET_2 \
	--query 'Instances[0].InstanceId' \
	--output text)
awslocal ec2 wait instance-running --instance-ids $EC1_INSTANCE_ID
EC1_PUBLIC_IP=$(awslocal ec2 describe-instances --instance-ids $EC1_INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)


## S3
awslocal s3 mb s3://my-local-bucket
awslocal s3 sync ~/code/aws-three-tier-web-architecture-workshop/ s3://my-local-bucket/