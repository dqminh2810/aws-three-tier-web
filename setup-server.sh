#!/bin/bash
set -e

SG_4_ID=$1
SG_5_ID=$2
SUBNET_2=$3
SUBNET_3=$4
SUBNET_6=$5

## RDS
awslocal rds create-db-subnet-group \
    --db-subnet-group-name my-subnet-group \
    --db-subnet-group-description "My LocalStack DB Subnet Group" \
    --subnet-ids $SUBNET_3 $SUBNET_6


awslocal rds create-db-cluster \
	--db-cluster-identifier my-db-cluster \
	--engine aurora-postgresql \
	--database-name testdb \
	--master-username admin \
	--master-user-password password


awslocal rds create-db-instance \
    --db-instance-identifier my-db-instance \
	--db-cluster-identifier my-db-cluster \
	--port 4510 \
    --engine aurora-postgresql \
    --db-instance-class db.r5.large \
	--availability-zone us-east-1a \
    --db-subnet-group-name my-subnet-group \
    --vpc-security-group-ids $SG_5_ID \
    --publicly-accessible # Set based on your testing needs (public or private subnets)
	
## EC2 VM
awslocal ec2 create-key-pair \
	--key-name my-key \
	--query 'KeyMaterial' \
	--output text > my-key.pem

chmod 400 my-key.pem

awslocal ec2 run-instances \
    --image-id ami-df5de72bdb3b \
    --count 1 \
    --instance-type t3.micro \
    --key-name my-key \
    --security-group-ids $SG_4_ID \
    --subnet-id $SUBNET_2
	
## S3
awslocal s3 mb s3://my-local-bucket
awslocal s3 sync ~/code/aws-three-tier-web-architecture-workshop/ s3://my-local-bucket/