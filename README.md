# AWS THREE TIER WEB
Build Secure, and High-Performance Web Applications scalable following 2 styles EKS or AutoScaling , with 3-Tier Architecture

## REQUIREMENT
- localstack ver Pro
- docker
- CLI aws / awslocal
- terraform
  
## CHECK LIST AWS COMPONENTS
#### APPLICATION COMPONENT
- EC2 VM
- RDS
- S3

#### NETWORK COMPONENT
- ELB
- INTERNET GATEWAY
- NAT GATEWAY

#### NETWORK MANAGEMENT ABSTRACTION
- VPC
- SUBNET
- AVAILABILITY ZONE
- ROUTE TABLE
- SECURITY GROUP

#### SCALE
- EKS
- AUTO SCALING

## SETUP
### LocalStack Server
- Update your LocalStack token [./docker-compose.yaml]

- `docker compose up` || `docker compose down` || `docker ps -qa | xargs docker rm`

### AWS Components - EKS Version
#### LocalStack
- `cd setup/eks && source setup.sh`

- Follow `k8s.sh` to create k8s elements

#### Terraform + AWS
`Check it out`

### AWS Components - Standard Verison (with AutoScaling)
#### LocalStack
- Update your DB address [./application-code/app-tier/DbConfig.js]

- `cd setup/standard && source setup.sh`

#### Terraform + AWS
- `cd terraform/standard`

- `terraform init`

- `terraform plan`

- `terraform apply`

- `terraform destroy` 

## CHECK
- Show output info - `cat output.txt`

- Check db tier working - `curl <WEB_TIER_LB_DNS_NAME>:<4566:80>/api/transaction`

- Check app tier health - `curl <WEB_TIER_LB_DNS_NAME>:<4566:80>/api/health`

- Check web tier health - `curl <WEB_TIER_LB_DNS_NAME>:<4566:80>/health`

## ARCHITECTURE
### EKS
![Components_architecture_EKS](https://github.com/dqminh2810/aws-three-tier-web/blob/main/docs/eks-3-tier-architecture.png)

### Standard vesrion - with Auto Scaling
![Components_architecture_ASG](https://github.com/dqminh2810/aws-three-tier-web/blob/main/docs/3-tier-architecture.png)