#!/bin/bash
set -e

SUBNET_1_ID=$1
SUBNET_2_ID=$2
VPC_ID=$3

SG_RDS_ID=$(awslocal ec2 create-security-group \
	--group-name postgressg  \
	--description "SG for RDS" \
	--vpc-id $VPC_ID \
	--query 'GroupId' \
	--output text)

NODE_SG=$(awslocal eks describe-cluster \
    --name eks-demo \
    --region us-east-1 \
    --query "cluster.resourcesVpcConfig.securityGroupIds[0]" \
    --output text)


# Allow cluster to reach rds on port 4510
awslocal ec2 authorize-security-group-ingress \
  --group-id $SG_RDS_ID \
  --protocol tcp \
  --port 4511 \
  --source-group $NODE_SG \
  --region us-east-1


## RDS
#### RDS - Subnet Group
awslocal rds create-db-subnet-group \
  --db-subnet-group-name my-rds-subnet-group \
  --db-subnet-group-description "Private subnet group for PostgreSQL RDS" \
  --subnet-ids $SUBNET_1_ID $SUBNET_2_ID \
  --region us-east-1

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
	--port 4511 \
    --engine aurora-postgresql \
    --db-instance-class db.r5.large \
	--availability-zone us-east-1a \
    --db-subnet-group-name my-rds-subnet-group \
    --vpc-security-group-ids $SG_RDS_ID \
    --publicly-accessible

#### RDS - Instance - AZ2 / us-east-1c
awslocal rds create-db-instance \
    --db-instance-identifier my-db-instance-az2 \
	--db-cluster-identifier my-db-cluster \
	--port 4511 \
    --engine aurora-postgresql \
    --db-instance-class db.r5.large \
	--availability-zone us-east-1c \
    --db-subnet-group-name my-rds-subnet-group \
    --vpc-security-group-ids $SG_RDS_ID \
    --publicly-accessible
	
## Init DB
awslocal rds wait db-cluster-available --db-cluster-identifier my-db-cluster
awslocal rds wait db-instance-available --db-instance-identifier my-db-instance-az1
awslocal rds wait db-instance-available --db-instance-identifier my-db-instance-az2