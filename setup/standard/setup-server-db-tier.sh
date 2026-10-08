#!/bin/bash
set -e

if [[ $# -ne 3 ]]; then
    echo "Error Usage : $0 <SG_5_ID> <SUBNET_3> <SUBNET_6>"
    exit 1
fi

SG_5_ID=$1
SUBNET_3=$2
SUBNET_6=$3

## RDS
aws rds create-db-subnet-group \
    --db-subnet-group-name my-subnet-group \
    --db-subnet-group-description "My LocalStack DB Subnet Group" \
    --subnet-ids $SUBNET_3 $SUBNET_6

#### RDS - Cluster 
aws rds create-db-cluster \
	--db-cluster-identifier my-db-cluster \
	--engine aurora-postgresql \
	--database-name testdb \
	--master-username root \
	--master-user-password rootpassword

#### RDS - Instance - AZ1 / ap-southeast-1a
aws rds create-db-instance \
    --db-instance-identifier my-db-instance-az1 \
	--db-cluster-identifier my-db-cluster \
    --engine aurora-postgresql \
    --db-instance-class db.r5.large \
	--availability-zone ap-southeast-1a \
    --publicly-accessible
	
## Init DB
aws rds wait db-cluster-available --db-cluster-identifier my-db-cluster
aws rds wait db-instance-available --db-instance-identifier my-db-instance-az1

## Migrate data to RDS
RDSHOST=$(aws rds describe-db-instances --db-instance-identifier my-db-instance-az1 --query 'DBInstances[0].Endpoint.Address' --output text)
PGPASSWORD="rootpassword" psql "host=$RDSHOST port=5432 dbname=testdb user=root sslmode=verify-full sslrootcert=./global-bundle.pem" -f initDB.sql