#!/bin/bash
set -e

# Setup S3
APPLICATION_CODE_DIR="$HOME/Code/aws-three-tier-web/application-code"
BUCKET_NAME="my-custom-bucket-xyz-2026"
if aws s3 ls "s3://$BUCKET_NAME" >/dev/null 2>&1; then
    echo "Success: Bucket '$BUCKET_NAME' exists and is accessible."
else
    echo "Error: Bucket '$BUCKET_NAME' does not exist, or access is denied."
	aws s3 mb s3://$BUCKET_NAME
	echo "Bucket '$BUCKET_NAME' created successfully."
fi

aws s3 sync $APPLICATION_CODE_DIR s3://$BUCKET_NAME

# Setup AWS network
source ./setup-network.sh

# Setup RDS
source ./setup-server-db-tier.sh $SG_5_ID $SUBNET_3 $SUBNET_6

# Setup EC2 Instance for app-tier
source ./setup-server-app-tier.sh $SG_4_ID $SUBNET_2 $SUBNET_5

# Setup app-tier internal LB
source ./setup-app-tier-internal-load-balancer.sh $VPC_ID $SG_3_ID $SUBNET_2 $SUBNET_5 $EC1_INSTANCE_ID

# Setup EC2 Instance for web-tier
source ./setup-server-web-tier.sh $SG_2_ID $SUBNET_1 $SUBNET_4 $APP_TIER_LB_DNS_NAME

# Setup web-tier external LB
source ./setup-web-tier-external-load-balancer.sh $VPC_ID $SG_1_ID $SUBNET_1 $SUBNET_4 $EC3_INSTANCE_ID

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
	 "APP_TIER_TG_ARN = $APP_TIER_TG_ARN"
	 "APP_TIER_LB_ARN = $APP_TIER_LB_ARN"
	 "APP_TIER_LB_DNS_NAME = $APP_TIER_LB_DNS_NAME"
	 "APP_TIER_LT_ID = $APP_TIER_LT_ID"
	 "APP_TIER_AS_ID = $APP_TIER_AS_ID"
	 
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