/**
resource "aws_db_subnet_group" "db_subnet" {
    name = "my-subnet-group" 
    subnet_ids = [ var.pri_sub_5_id,var.pri_sub_6_id]
}

resource "aws_rds_cluster" "db_cluster" {
    cluster_identifier      = "my-db-cluster"
    engine                  = "aurora-postgresql"
    availability_zones      = ["us-east-1a", "us-east-1c"]
    database_name           = var.db_name
    master_username         = var.db_username
    master_password         = var.db_password
    vpc_security_group_ids  = [var.db_sg_id]
}

resource "aws_rds_cluster_instance" "db_cluster_instance_1" {
    count              = 1
    identifier         = "my-db-cluster-${count.index}"
    cluster_identifier = aws_rds_cluster.db_cluster.id
    instance_class     = "db.r5.large"
    engine             = aws_rds_cluster.db_cluster.engine
    engine_version     = aws_rds_cluster.db_cluster.engine_version
    #port               = var.db_port
    db_subnet_group_name = aws_db_subnet_group.db_subnet.name
    availability_zone  = "us-east-1a"
}

resource "aws_rds_cluster_instance" "db_cluster_instance_2" {
    count              = 1
    identifier         = "my-db-cluster-${count.index}"
    cluster_identifier = aws_rds_cluster.db_cluster.id
    instance_class     = "db.r5.large"
    engine             = aws_rds_cluster.db_cluster.engine
    engine_version     = aws_rds_cluster.db_cluster.engine_version
    #port               = var.db_port
    db_subnet_group_name = aws_db_subnet_group.db_subnet.name
    availability_zone  = "us-east-1c"
}

resource "null_resource" "db_init_data" {
    provisioner "local-exec" {
        # command to execute the SQL script using the mysql CLI
        # It passes the RDS endpoint, username, and password as environment variables for security/convenience
        command = <<-EOF
            mysql --host=${aws_rds_cluster.db_cluster.endpoint} \
                  --port=${aws_rds_cluster.db_cluster.port} \
                  --user=${aws_rds_cluster.db_cluster.master_username} \
                  --password=${aws_rds_cluster.db_cluster.master_password} \
                  --database=${aws_rds_cluster.db_cluster.database_name} < ./initDB.sql
        EOF
    }
    depends_on = [aws_rds_cluster_instance.db_cluster_instance_1, aws_rds_cluster_instance.db_cluster_instance_2]
}
**/