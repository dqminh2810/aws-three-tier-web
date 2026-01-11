# AWS THREE TIER WEB

## REQUIREMENT
- awslocal CLI
- localstack ver Pro
- docker

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


## SETUP
#### LocalStack
- Update your DB address [./application-code/app-tier/DbConfig.js] & LocalStack token [./docker-compose.yaml]

- `docker compose up` || `docker compose down` || `docker ps -qa | xargs docker rm`

- `cd setup && source setup.sh`

#### AWS
- `terraform init`

- `terraform plan`

- `terraform apply -auto-approve`

- `terraform destroy -auto-approve` 

## CHECK
- Show output info - `cat output.txt`

- Check web tier health - `curl <WEB_TIER_LB_DNS_NAME>:4566/health`

- Check app tier health - `curl <WEB_TIER_LB_DNS_NAME>:4566/api/health`

- Check db tier working - `curl <WEB_TIER_LB_DNS_NAME>:4566/api/transaction`

## ARCHITECTURE
![Components_architecture](https://github.com/dqminh2810/aws-three-tier-web/blob/main/docs/3-tier-architecture.png)

![RT_architecture](https://github.com/dqminh2810/aws-three-tier-web/blob/main/docs/route-table.png)

