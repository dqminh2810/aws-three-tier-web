#!/bin/bash
set -e

VPC_ID=$1
SUBNET_1=$2
SUBNET_4=$3
SG_1_ID=$4
EC3_INSTANCE_ID=$5

# Create target group
WEB_TIER_TG_ARN=$(awslocal elbv2 create-target-group \
  --name web-tier-tg \
  --protocol HTTP \
  --port 80 \
  --vpc-id $VPC_ID\
  --target-type instance \
  --health-check-protocol HTTP \
  --health-check-port 80 \
  --health-check-path /health \
  | jq -r '.TargetGroups[].TargetGroupArn')


# Create load balancer
WEB_TIER_LB_ARN=$(awslocal elbv2 create-load-balancer \
    --name web-tier-external-lb \
    --type application \
	--scheme internet-facing \
    --subnets $SUBNET_1 $SUBNET_4 \
    --security-groups $SG_1_ID \
	| jq -r '.LoadBalancers[0].LoadBalancerArn')


# Forward traffic from load balancer to target group
awslocal elbv2 create-listener \
    --load-balancer-arn $WEB_TIER_LB_ARN \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$WEB_TIER_TG_ARN

WEB_TIER_LB_DNS_NAME=$(awslocal elbv2 describe-load-balancers --load-balancer-arns $WEB_TIER_LB_ARN --query 'LoadBalancers[0].DNSName' --output text)


# Create Launch Template
WEB_TIER_LT_ID=$(awslocal ec2 create-launch-template \
    --launch-template-name web-tier-launch-template \
    --version-description v1 \
    --launch-template-data '{
        "ImageId": "ami-000001",
        "InstanceType": "t3.micro",
		"SecurityGroupIds": ["'$SG_2_ID'"]
    }' \
	--query 'LaunchTemplate.LaunchTemplateId' --output text)


# Create Auto Scaling
awslocal autoscaling create-auto-scaling-group \
    --auto-scaling-group-name web-tier-asg \
    --launch-template LaunchTemplateId=$WEB_TIER_LT_ID \
    --min-size 1 \
    --max-size 5 \
    --vpc-zone-identifier "$SUBNET_1,$SUBNET_4" \
	--target-group-arns $WEB_TIER_TG_ARN
	
	
## Only for localstack bcz it do not create the real instance automatically but rather the mock ones
awslocal autoscaling attach-instances \
    --instance-ids $EC3_INSTANCE_ID \
    --auto-scaling-group-name web-tier-asg