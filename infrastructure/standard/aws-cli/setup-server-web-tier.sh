#!/bin/bash
set -e

if [[ $# -ne 4 ]]; then
    echo "Error Usage : $0 <SG_2_ID> <SUBNET_1> <SUBNET_4> <APP_TIER_LB_DNS_NAME>"
    exit 1
fi

SG_2_ID=$1
SUBNET_1=$2
SUBNET_4=$3
APP_TIER_LB_DNS_NAME=$4

# EC2 VM
## Setup EC2 Instance - AZ1/ap-southeast-1a
EC3_INSTANCE_ID=$(aws ec2 run-instances \
    --image-id ami-0532913178263be11 \
    --instance-type t3.micro \
    --count 1 \
    --subnet-id $SUBNET_1 \
    --security-group-ids $SG_2_ID \
    --associate-public-ip-address \
	--iam-instance-profile Name="EC2-SSM-Role" \
	--query 'Instances[0].InstanceId' \
	--output text)

## Check EC2 status
aws ec2 wait system-status-ok --instance-ids $EC3_INSTANCE_ID
aws ec2 wait instance-status-ok --instance-ids $EC3_INSTANCE_ID
while true; do
    # Truy vấn trạng thái bài kiểm tra EBS đính kèm của dòng máy Nitro mới
	EBS_CHECK=$(aws ec2 describe-instance-status \
		--instance-ids "$EC3_INSTANCE_ID" \
		--query "InstanceStatuses[0].AttachedEbsStatus.Status" \
		--output text 2>/dev/null)

	# Nếu bài check ổ đĩa báo "ok", nghĩa là đã đạt đủ 3/3 checks passed
	if [ "$EBS_CHECK" = "ok" ]; then
		echo "✅ Tuyệt vời! Ổ đĩa ổn định. Đã đạt trạng thái 3/3 checks passed!"
		break
	fi

	echo "⏳ Bài check ổ cứng hiện tại: [$EBS_CHECK]. Đang đợi thêm 10 giây..."
	sleep 10
done

EC3_PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $EC3_INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

## Install EC2 instance dependencies
jq --arg dns_name "$APP_TIER_LB_DNS_NAME" '.commands[] |= gsub("\\[APP_TIER_LB_DNS_NAME\\]"; $dns_name)' install-server-web-tier.json > tmp.json
# Connect via SSM
aws ssm send-command \
    --document-name "AWS-RunShellScript" \
    --instance-ids "$EC3_INSTANCE_ID" \
    --parameters file://tmp.json