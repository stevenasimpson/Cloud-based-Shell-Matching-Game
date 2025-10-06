provider "aws" {
    region = "us-east-1"
}

#default vpc
data "aws_vpc" "default" {
    default = true
}

#default subnet
data "aws_subnets" "default" {
    filter {
        name    = "vpc-id"
        values  = [data.aws_vpc.default.id]
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
        description     = "MySQL from anywhere"
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

resource "aws_instance" "web_server" {
    ami             = "ami-052064a798f08f0d3"
    instance_type   = "t2.micro"
    key_name        = "cosc349-2025"

    vpc_security_group_ids = [aws_security_group.allow_ssh.allow_ssh.id, aws_security_group.allow_ssh.allow_api.id, allow_ssh.allow_web.id]

    user_data = templatefile("${path.module}/build-webserver-vm.tpl", { api_server_ip = aws.instance.api_server.private_ip })

    tags = {
        Name = "shell_game_webserver"
    }
}

resource "aws_instance" "api_server" {
    ami             = "ami-052064a798f08f0d3"
    instance_type   = "t2.micro"
    key_name        = "cosc349-2025"

    vpc_security_group_ids = [aws_security_group.allow_ssh.allow_ssh.id, aws_security_group.allow_ssh.allow_api.id, allow_ssh.allow_web.id, allow_ssh.allow_mysql.id]

    user_data = templatefile("${path.module}/build-apiserver-vm.tpl", { mysql_server_ip = aws_db_instance.mysql_server.private_ip, web_server_ip = aws_instance.web_server.private_ip })

    tags = {
        Name = "shell_game_apiserver"
    }
}

resource "aws_db_instance" "mysql_server" {
    identifier = "shell-game-mysql-server"

    engine          = "mysql"
    engine_version  = "8.0"
    instance_class  = "db.t3.micro"


    vpc_security_group_ids = [aws_security_group.allow_ssh.allow_ssh.id, aws_security_group.allow_ssh.allow_api.id, allow_ssh.allow_mysql.id]

    user_data = templatefile("${path.module}/build-dbserver-vm.tpl", { mysql_server_ip = aws_db_instance.mysql_server.private_ip, api_server_ip = aws_instance.api_server.private_ip })

    tags = {
        Name = "shell-game-mysql-server"
    }
}

output "web_server_ip" {
  value = aws_instance.web_server.public_ip
}

output "api_server_ip" {
  value = aws_instance.api_server.public_ip
}

output "mysql_server_ip" {
  value = aws_db_instance.mysql_server.public_ip
}

