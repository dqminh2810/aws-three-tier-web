#!/bin/bash
set -e

# Setup EKS cluster
source ./setup-eks-cluster.sh

# Setup RDS
source ./setup-server-db-tier.sh $SUBNET_1_ID $SUBNET_2_ID $VPC_ID

# OUTPUT
cat <<EOF > output.txt
	"*******VPC*******"
	"VPC_ID = $VPC_ID"

	"*******SUBNET*******"
	"SUBNET_1_ID = $SUBNET_1_ID"
	"SUBNET_2_ID = $SUBNET_2_ID"

	"*******SECURITY GROUP*******"
	"SG_EKS_ID = $SG_EKS_ID"
    "SG_RDS_ID = $SG_RDS_ID"
EOF