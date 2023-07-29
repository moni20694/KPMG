resource "aws_security_group" "frontend_sg" {
  name_prefix = "frontend_sg"
  description = "Security group for frontend tier"
  # Allow incoming traffic only from the ALB security group
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "this" {
  key_name   = var.key_name
  public_key = tls_private_key.this.public_key_openssh
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

resource "aws_instance" "frontend_instance" {
  ami           = "ami-xxxx"  
  instance_type = "t2.micro"  
  key_name      = aws_key_pair.this.key_name 
  security_groups = [aws_security_group.frontend_sg.id]
  userdata = file("./userdata.sh.tpl") 
}

resource "aws_lb" "frontend_lb" {
  name               = "frontend-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = 
  security_groups = [aws_security_group.frontend_sg.id]
}

# Application tier

resource "aws_security_group" "application_sg" {
  name_prefix = "application_sg"
  description = "Security group for application tier"
  # Allow incoming traffic only from the web tier security group
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
  
resource "aws_key_pair" "application" {
  key_name   = var.key_name
  public_key = tls_private_key.application.public_key_openssh
}
  
resource "tls_private_key" "application" {
  algorithm = "RSA"
}
  
resource "aws_instance" "application_instance" {
  ami           = "ami-xxxx"  
  instance_type = "t2.micro"  
  key_name      = aws_key_pair.application.key_name 
  security_groups = [aws_security_group.application_sg.id]
  userdata = file("./userdata.sh.tpl") 
}
  
resource "aws_lb" "application_lb" {
  name               = "application-lb"
  internal           = true
  load_balancer_type = "application"
  subnets            = 
  security_groups = [aws_security_group.application_sg.id]
}

# Database tier

resource "aws_security_group" "db_sg" {
  name_prefix = "db_sg"
  description = "Security group for database tier"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
resource "aws_db_instance" "database_instance" {
  engine                 = "oracle" 
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"  
  allocated_storage      = 20
  max_allocated_storage  = 100
  identifier             = "my-database"
  username               = "foo"
  password               = "foobarbaz"
  vpc_security_group_ids = aws_security_group.db_sg.id
}

