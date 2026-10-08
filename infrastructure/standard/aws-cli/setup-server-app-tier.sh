#!/bin/bash
set -e

if [[ $# -ne 3 ]]; then
    echo "Error Usage : $0 <SG_4_ID> <SUBNET_2> <SUBNET_5>"
    exit 1
fi

SG_4_ID=$1
SUBNET_2=$2
SUBNET_5=$3
	
# EC2 VM
## Create EC2 Instance - AZ1/us-east-1a
EC1_INSTANCE_ID=$(aws ec2 run-instances \
    --image-id ami-0532913178263be11 \
    --count 1 \
    --instance-type t3.micro \
    --security-group-ids $SG_4_ID \
    --subnet-id $SUBNET_2 \
    --associate-public-ip-address \
	--iam-instance-profile Name="EC2-SSM-Role" \
	--query 'Instances[0].InstanceId' \
	--output text)

## Check EC2 status
aws ec2 wait system-status-ok --instance-ids $EC1_INSTANCE_ID
aws ec2 wait instance-status-ok --instance-ids $EC1_INSTANCE_ID
while true; do
	# Truy vấn trạng thái bài kiểm tra EBS đính kèm của dòng máy Nitro mới
	EBS_CHECK=$(aws ec2 describe-instance-status \
		--instance-ids "$EC1_INSTANCE_ID" \
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

EC1_PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $EC1_INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
EC1_PRIVATE_IP=$(aws ec2 describe-instances --instance-ids $EC1_INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)

# ## Install EC2 instance dependencies
# Execute commands on the EC2 instance using standard SSH with the generated key pair
# source ./install-server-app-tier.sh ./my-key.pem admin $EC1_PUBLIC_IP
	
# Execute commands on the EC2 instance using EC2 Instance Connect
# aws ec2-instance-connect ssh \
    # --instance-id $EC1_INSTANCE_ID \
    # --connection-type eice \
    # --region ap-southeast-1 \
    # --os-user ubuntu \
    # < test.sh

# Execute commands on the EC2 instance using AWS Systems Manager (SSM)
aws ssm send-command \
    --document-name "AWS-RunShellScript" \
    --instance-ids "$EC1_INSTANCE_ID" \
	--parameters file://install-server-app-tier.json