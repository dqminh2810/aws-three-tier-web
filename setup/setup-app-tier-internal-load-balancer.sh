#!/bin/bash
set -e

VPC_ID=$1
SUBNET_2=$2
SUBNET_5=$3
SG_4_ID=$4
EC2_INSTANCE_ID=$5

# Create target group
TG_ARN=$(awslocal elbv2 create-target-group \
  --name app-tier-tg \
  --protocol HTTP \
  --port 4000 \
  --vpc-id $VPC_ID\
  --target-type instance \
  --health-check-protocol HTTP \
  --health-check-port 4000 \
  --health-check-path /health \
  | jq -r '.TargetGroups[].TargetGroupArn')


# Create load balancer
LB_ARN=$(awslocal elbv2 create-load-balancer \
    --name app-tier-internal-lb \
    --type application \
	--scheme internal \
    --subnets $SUBNET_2 $SUBNET_5 \
    --security-groups $SG_4_ID \
	| jq -r '.LoadBalancers[0].LoadBalancerArn')


# Forward traffic from load balancer to target group
awslocal elbv2 create-listener \
    --load-balancer-arn $LB_ARN \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$TG_ARN

LB_DNS_NAME=$(awslocal elbv2 describe-load-balancers --load-balancer-arns $LB_ARN --query 'LoadBalancers[0].DNSName' --output text)


# Create Launch Template
LT_ID=$(awslocal ec2 create-launch-template \
    --launch-template-name app-tier-launch-template \
    --version-description v1 \
    --launch-template-data '{
        "ImageId": "ami-000001",
        "InstanceType": "t3.micro",
		"SecurityGroupIds": ["'$SG_4_ID'"]
    }' \
	--query 'LaunchTemplate.LaunchTemplateId' --output text)


# Create Auto Scaling
awslocal autoscaling create-auto-scaling-group \
    --auto-scaling-group-name app-tier-asg \
    --launch-template LaunchTemplateId=$LT_ID \
    --min-size 1 \
    --max-size 5 \
    --vpc-zone-identifier "$SUBNET_2,$SUBNET_5" \
	--target-group-arns $TG_ARN
	
	
## Only for localstack bcz it do not create the real instance automatically but rather the mock ones
awslocal autoscaling attach-instances \
    --instance-ids $EC2_INSTANCE_ID \
    --auto-scaling-group-name app-tier-asg