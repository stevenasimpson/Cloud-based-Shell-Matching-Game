provider "aws" {
    region = "us-east-1"
}

data "aws_availability_zones" "available" {
    state = "available"
}

data "aws_subnets" "default" {
    filter {
        name    = "availability-zone"
        values  = slice(data.aws_availability_zones.available.names, 0, 2)
    }

    filter {
        name    = "default-for-az"
        values  = ["true"]
    }
}

resource "aws_db_subnet_group" "mysql_subnet_group" {
    name        = "mysql_subnet_group"
    subnet_ids  = data.aws_subnets.default.ids

    tags = {
        Name = "MySQL DB Subnet Group"
    }
}

resource "aws_security_group" "allow_ssh" {
    name        = "allow_ssh"
    description = "Allow inbound SSH traffic"

    ingress {
        description = "SSH from anywhere"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]   
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]   
    }
}

resource "aws_security_group" "allow_web" {
    name        = "allow_web"
    description = "Allow inbound HTTP(S) traffic"

    ingress {
        description = "HTTP from anywhere"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]   
    }

    ingress {
        description = "HTTPS from anywhere"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]   
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]   
    }
}

resource "aws_security_group" "allow_api" {
    name        = "allow_api"
    description = "Allow inbound Web/DB traffic"

    ingress {
        description = "HTTP from anywhere"
        from_port   = 8888
        to_port     = 8888
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]   
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]   
    }
}

resource "aws_security_group" "allow_mysql" {
    name        = "allow_mysql"
    description = "Allow inbound MySQL traffic"

    ingress {
        description     = "MySQL from VPC"
        from_port       = 3306
        to_port         = 3306
        protocol        = "tcp" 
        cidr_blocks = ["0.0.0.0/0"]  
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]   
    }
}

resource "aws_db_instance" "mysql_server" {
    identifier = "shell-game-mysql-server"

    engine          = "mysql"
    engine_version  = "8.0"
    instance_class  = "db.t3.micro"

    allocated_storage = 20

    db_name         = "fvision"
    username        = "webuser"
    password        = "insecure_db_pw"


    vpc_security_group_ids  = [aws_security_group.allow_mysql.id]
    db_subnet_group_name    = aws_db_subnet_group.mysql_subnet_group.name

    publicly_accessible = false
    skip_final_snapshot = true

    tags = {
        Name = "shell-game-mysql-server"
    }
}

resource "aws_instance" "api_server" {
    ami             = "ami-0360c520857e3138f"
    instance_type   = "t2.micro"
    key_name        = "cosc349-2025"

    vpc_security_group_ids = [
        aws_security_group.allow_ssh.id, 
        aws_security_group.allow_api.id
    ]

    user_data = templatefile("${path.module}/build-apiserver-vm.tpl", {     mysql_server_endpoint = aws_db_instance.mysql_server.endpoint })

    depends_on = [aws_db_instance.mysql_server]

    tags = {
        Name = "shell_game_apiserver"
    }
}

resource "aws_instance" "web_server" {
    ami             = "ami-0360c520857e3138f"
    instance_type   = "t2.micro"
    key_name        = "cosc349-2025"

    vpc_security_group_ids = [
        aws_security_group.allow_ssh.id, 
        aws_security_group.allow_web.id
    ]

    user_data = templatefile("${path.module}/build-webserver-vm.tpl", { api_server_ip = aws_instance.api_server.private_ip })

    depends_on = [aws_instance.api_server]

    tags = {
        Name = "shell_game_webserver"
    }
}

output "web_server_ip" {
  value = aws_instance.web_server.public_ip
}

output "api_server_ip" {
  value = aws_instance.api_server.public_ip
}

output "mysql_server_ip" {
  value = aws_db_instance.mysql_server.endpoint
}

