#!/bin/bash
set -e

SG_5_ID=$1
SUBNET_3=$2
SUBNET_6=$3

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
	
## Init DB
awslocal rds wait db-cluster-available --db-cluster-identifier my-db-cluster
awslocal rds wait db-instance-available --db-instance-identifier my-db-instance-az1
awslocal rds wait db-instance-available --db-instance-identifier my-db-instance-az2
PGPASSWORD="password" psql -d testdb -U admin -p 4510 -h localhost -f initDB.sql