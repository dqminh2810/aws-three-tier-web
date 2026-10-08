#!/bin/bash
set -e

# REBUILD=$1
# SSH_KEY_PEM_FILE="./my-key.pem"

# if [ ! -f "$SSH_KEY_PEM_FILE" ]; then
# 	REBUILD="--build"
# fi

# if [[ $REBUILD == "--build" ]]; then
# 	echo "***EC2 image will be rebuild***"
# 	rm -f my-key.pem
# 	aws ec2 create-key-pair --key-name my-key --query 'KeyMaterial' --output text > my-key.pem
# else
# 	echo "***Please check previous EC2 image localstack-ec2/ubuntu-22.04-jammy-jellyfish:ami-000001***"
# fi

# Setup AWS network
source ./setup-network.sh

# Setup S3
# aws s3 mb s3://my-custom-bucket-xyz-2026
aws s3 sync /home/dqminh/Code/aws-three-tier-web/application-code s3://my-custom-bucket-xyz-2026


# Setup web-tier external LB
# source ./setup-web-tier-external-load-balancer.sh $VPC_ID $SUBNET_1 $SUBNET_4 $SG_1_ID $EC3_INSTANCE_ID

# # Setup EC2 Instance for app-tier
# source ./setup-server-app-tier.sh $SG_4_ID $SUBNET_2 $SUBNET_5 $REBUILD
source ./setup-server-app-tier.sh $SG_4_ID $SUBNET_2

# # Setup app-tier internal LB
# source ./setup-app-tier-internal-load-balancer.sh $VPC_ID $SUBNET_2 $SUBNET_5 $SG_4_ID $EC2_INSTANCE_ID

# Setup EC2 Instance for web-tier
#source ./setup-server-web-tier.sh $SG_2_ID $SUBNET_1 $SUBNET_4 $LB_DNS_NAME
source ./setup-server-web-tier.sh $SG_2_ID $SUBNET_1 $EC1_PRIVATE_IP

# # Setup RDS
# source ./setup-server-db-tier.sh $SG_5_ID $SUBNET_3 $SUBNET_6

# #### OUTPUT
cat <<EOF > output.txt
	 "*******VPC*******"
	 "VPC_ID = $VPC_ID"

	 "*******SUBNET*******"
	 "SUBNET_1 = $SUBNET_1"
	 "SUBNET_2 = $SUBNET_2"
	 "SUBNET_3 = $SUBNET_3"
	 "SUBNET_4 = $SUBNET_4"
	 "SUBNET_5 = $SUBNET_5"
	 "SUBNET_6 = $SUBNET_6"

	 "*******GATEWAY*******"
	 "IGW_ID = $IGW_ID"
	 "EIP_1_ID = $EIP_1_ID"
	 "NGW_1_ID = $NGW_1_ID"
	 "EIP_2_ID = $EIP_2_ID"
	 "NGW_2_ID = $NGW_2_ID"

	 "*******ROUTE TABLE*******"
	 "PUBLIC_RT_ID = $PUBLIC_RT_ID"
	 "PRIVATE_RT_1_ID = $PRIVATE_RT_1_ID"
	 "PRIVATE_RT_2_ID = $PRIVATE_RT_2_ID"

	 "*******SECURITY GROUP*******"
	 "SG_1_ID = $SG_1_ID"
	 "SG_2_ID = $SG_2_ID"
	 "SG_3_ID = $SG_3_ID"
	 "SG_4_ID = $SG_4_ID"
	 "SG_5_ID = $SG_5_ID"

	"*******INTERNAL LB*******"
	 "TG_ARN = $TG_ARN"
	 "LB_ARN = $LB_ARN"
	 "LB_DNS_NAME = $LB_DNS_NAME"
	 "LT_ID = $LT_ID"
	 "AS_ID = $AS_ID"
	 
	 "*******EXTERNAL LB*******"
	 "WEB_TIER_TG_ARN = $WEB_TIER_TG_ARN"
	 "WEB_TIER_LB_ARN = $WEB_TIER_LB_ARN"
	 "WEB_TIER_LB_DNS_NAME = $WEB_TIER_LB_DNS_NAME"
	 "WEB_TIER_LT_ID = $WEB_TIER_LT_ID"
	 "WEB_TIER_AS_ID = $WEB_TIER_AS_ID"	 

	 "*******EC2 VM*******"
	 "EC1_INSTANCE_ID = $EC1_INSTANCE_ID"
	 "EC2_INSTANCE_ID = $EC2_INSTANCE_ID"
	 "EC3_INSTANCE_ID = $EC3_INSTANCE_ID"
	 "EC4_INSTANCE_ID = $EC4_INSTANCE_ID"

	 "EC1_PUBLIC_IP = $EC1_PUBLIC_IP"
	 "EC1_PRIVATE_IP = $EC1_PRIVATE_IP"

	 "EC2_PUBLIC_IP = $EC2_PUBLIC_IP"
	 "EC2_PRIVATE_IP = $EC2_PRIVATE_IP"

	 "EC3_PUBLIC_IP = $EC3_PUBLIC_IP"
	 "EC3_PRIVATE_IP = $EC3_PRIVATE_IP"
	 
	 "EC4_PUBLIC_IP = $EC4_PUBLIC_IP"
	 "EC4_PRIVATE_IP = $EC4_PRIVATE_IP"

	 *******RDS*******"
	 "RDSHOST = $RDSHOST"
EOF