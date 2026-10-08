# AWS THREE TIER WEB
Build Secure, and High-Performance Web Applications scalable following 2 styles EKS or AutoScaling , with 3-Tier Architecture

## REQUIREMENT
- AWS CLI
- docker
- terraform
  
## CHECK LIST AWS COMPONENTS
#### NETWORK MANAGEMENT ABSTRACTION
- VPC
- SUBNET
- AVAILABILITY ZONE
- ROUTE TABLE
- SECURITY GROUP

#### NETWORK COMPONENT
- ELB
- INTERNET GATEWAY
- NAT GATEWAY

#### APPLICATION COMPONENT
- EC2 VM
- RDS
- S3

#### REMOTE ACCESS & ROLE PERMISSION MANAGEMENT  
- SSM
- IAM

#### SCALE
- EKS
- AUTO SCALING

## SETUP
### Standard Version with AWS CLI
Applications deployed on EC2 & the infrastructure been setup with AWS CLI

`./infrastructure/standard/aws-cli/setup.sh`

### Standard Version with Terraform
Applications deployed on EC2 & & the infrastructure been setup with Terraform

### EKS Version with AWS CLI
Applications deployed on EKS & the infrastructure been setup with AWS CLI

### EKS Version with Terraform
Applications deployed on EKS & the infrastructure been setup with Terraform

## CHECK
- Show output info - `cat output.txt`

- Check db tier working - `curl http://<EXTERNAL_LB_DNS_NAME>:80/api/transaction`

- Check app tier health - `curl http://<EXTERNAL_LB_DNS_NAME>:80/api/health`

- Check web tier health - `curl http://<EXTERNAL_LB_DNS_NAME>:80/health`

## ARCHITECTURE
### EKS
![Components_architecture_EKS](https://github.com/dqminh2810/aws-three-tier-web/blob/main/docs/eks-3-tier-architecture.png)

### Standard vesrion - with Auto Scaling
![Components_architecture_ASG](https://github.com/dqminh2810/aws-three-tier-web/blob/main/docs/3-tier-architecture.png)