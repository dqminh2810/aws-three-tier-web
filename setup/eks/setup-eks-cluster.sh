#!/bin/bash
set -e

# NETWORK
## VPC
VPC_ID=$(awslocal ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.{VpcId:VpcId}' --output text)

## SUBNET
SUBNET_1_ID=$(awslocal ec2 create-subnet \
	--vpc-id $VPC_ID \
	--cidr-block 10.0.1.0/24 \
	--availability-zone us-east-1a \
	--query 'Subnet.{SubnetId:SubnetId}' \
	--output text)
SUBNET_2_ID=$(awslocal ec2 create-subnet \
	--vpc-id $VPC_ID \
	--cidr-block 10.0.2.0/24 \
	--availability-zone us-east-1c \
	--query 'Subnet.{SubnetId:SubnetId}' \
	--output text)

## SECURITY GROUP
SG_EKS_ID=$(awslocal ec2 create-security-group \
	--group-name ekssg \
	--description "SG for EKS" \
	--vpc-id $VPC_ID \
	--query 'GroupId' \
	--output text)
awslocal ec2 authorize-security-group-ingress \
	--group-id $SG_EKS_ID \
	--protocol tcp \
	--port 22 \
	--cidr 0.0.0.0/0
awslocal ec2 authorize-security-group-ingress \
	--group-id $SG_EKS_ID \
	--protocol tcp \
	--port 80 \
	--cidr 0.0.0.0/0
awslocal ec2 authorize-security-group-ingress \
	--group-id $SG_EKS_ID \
	--protocol tcp \
	--port 443 \
	--cidr 0.0.0.0/0

# EKS
## EKS MASTER - CONTROL PANEL
awslocal eks create-cluster \
	--name eks-demo \
	--role-arn arn:awslocal:iam::*******************:role/custom=1 \
	--resources-vpc-config subnetIds=$SUBNET_1_ID,$SUBNET_2_ID,securityGroupIds=$SG_EKS_ID
awslocal eks wait cluster-active --name eks-demo
awslocal eks describe-cluster --name eks-demo

## EC2 SSH KEY
awslocal ec2 create-key-pair \
	--key-name my-key \
	--query 'KeyMaterial' \
	--output text > my-key.pem

## EKS WORKER - NODE GROUP
awslocal eks create-nodegroup \
	--cluster-name eks-demo \
	--nodegroup-name eks-demo-node-group \
	--remote-access ec2SshKey=my-key,sourceSecurityGroups=$SG_EKS_ID \
	--node-role arn:awslocal:iam::*************:role/custom=1 \
	--subnets $SUBNET_1_ID,$SUBNET_2_ID \
	--scaling-config minSize=2,maxSize=2,desiredSize=2 \
	--instance-types t3.medium \
	--ami-type AL2_x86_64
awslocal eks wait nodegroup-active --cluster-name eks-demo --nodegroup-name eks-demo-node-group
awslocal eks describe-nodegroup --cluster-name eks-demo --nodegroup-name eks-demo-node-group

## KUBECONFIG FILE
awslocal eks update-kubeconfig \
	--region us-east-1 \
	--name eks-demo

## KUBECTL
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl cluster-info