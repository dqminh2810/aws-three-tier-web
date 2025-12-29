# AWS THREE TIER WEB

## REQUIREMENT
- awslocal CLI
- docker

## CHECK LIST AWS COMPONENTS
#### APPLICATION COMPONENT
- EC2 VM
- DYNAMODB


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
- Setup AWS network - `. ./setup-network.sh`

- Setup AWS DB & EC2 Instance - `. ./setup-server.sh <SG_4_ID> <SG_5_ID> <SUBNET_2> <SUBNET_3> <SUBNET_6>`

- Init DB - `sudo apt-get install postgresql-client` then `psql -d testdb -U admin -p 4510 -h localhost -f ./initDB.sql -W`

- Install server dependencies - `. ./install-server.sql <SSH_KEY_PATH <REMOTE_USER> <REMOTE_HOST>`

## ARCHITECTURE
![Components_architecture](https://github.com/dqminh2810/aws-three-tier-web/blob/main/docs/3-tier-architecture.png)

![RT_architecture](https://github.com/dqminh2810/aws-three-tier-web/blob/main/docs/route-table.png)

