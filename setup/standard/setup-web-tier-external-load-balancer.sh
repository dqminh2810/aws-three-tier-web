#!/bin/bash
set -e

if [[ $# -ne 5 ]]; then
    echo "Error Usage : $0 <VPC_ID> <SG_1_ID> <SUBNET_1> <SUBNET_4> <EC3_INSTANCE_ID>"
    exit 1
fi

VPC_ID=$1
SG_1_ID=$2
SUBNET_1=$3
SUBNET_4=$4
EC3_INSTANCE_ID=$5

# TARGET GROUP
## Create target group
WEB_TIER_TG_ARN=$(aws elbv2 create-target-group \
  --name web-tier-tg \
  --protocol HTTP \
  --port 80 \
  --vpc-id $VPC_ID\
  --target-type instance \
  --health-check-protocol HTTP \
  --health-check-port 80 \
  --health-check-path /health \
  | jq -r '.TargetGroups[].TargetGroupArn')

# Register targets to target group
aws elbv2 register-targets \
    --target-group-arn $WEB_TIER_TG_ARN \
    --targets Id=$EC3_INSTANCE_ID

# LOAD BALANCER
## Create load balancer
WEB_TIER_LB_ARN=$(aws elbv2 create-load-balancer \
    --name web-tier-external-lb \
    --type application \
	--scheme internet-facing \
    --subnets $SUBNET_1 $SUBNET_4 \
    --security-groups $SG_1_ID \
	| jq -r '.LoadBalancers[0].LoadBalancerArn')

# LISTENER
## Forward traffic from load balancer to target group
aws elbv2 create-listener \
    --load-balancer-arn $WEB_TIER_LB_ARN \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$WEB_TIER_TG_ARN

WEB_TIER_LB_DNS_NAME=$(aws elbv2 describe-load-balancers --load-balancer-arns $WEB_TIER_LB_ARN --query 'LoadBalancers[0].DNSName' --output text)