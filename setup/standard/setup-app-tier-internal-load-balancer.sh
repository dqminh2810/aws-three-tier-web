#!/bin/bash
set -e
if [[ $# -ne 5 ]]; then
    echo "Error Usage : $0 <VPC_ID> <SG_3_ID> <SUBNET_2> <SUBNET_5> <EC1_INSTANCE_ID>"
    exit 1
fi

VPC_ID=$1
SG_3_ID=$2
SUBNET_2=$3
SUBNET_5=$4
EC1_INSTANCE_ID=$5

# TARGET GROUP
## Create target group
APP_TIER_TG_ARN=$(aws elbv2 create-target-group \
  --name app-tier-tg \
  --protocol HTTP \
  --port 4000 \
  --vpc-id $VPC_ID\
  --target-type instance \
  --health-check-protocol HTTP \
  --health-check-port 4000 \
  --health-check-path /health \
  | jq -r '.TargetGroups[].TargetGroupArn')

## Register targets to target group
aws elbv2 register-targets \
    --target-group-arn $APP_TIER_TG_ARN \
    --targets Id=$EC1_INSTANCE_ID

# LOAD BALANCER
## Create load balancer
APP_TIER_LB_ARN=$(aws elbv2 create-load-balancer \
    --name app-tier-internal-lb \
    --type application \
	--scheme internal \
    --subnets $SUBNET_2 $SUBNET_5 \
    --security-groups $SG_3_ID \
	| jq -r '.LoadBalancers[0].LoadBalancerArn')

# LISTENER
## Forward traffic from load balancer to target group
aws elbv2 create-listener \
    --load-balancer-arn $APP_TIER_LB_ARN \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$APP_TIER_TG_ARN

APP_TIER_LB_DNS_NAME=$(aws elbv2 describe-load-balancers --load-balancer-arns $APP_TIER_LB_ARN --query 'LoadBalancers[0].DNSName' --output text)