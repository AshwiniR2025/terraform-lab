# 1. Get your Default VPC (Network) automatically
data "aws_vpc" "default" {
  default = true
}

# 2. Create a Security Group (Firewall)
resource "aws_security_group" "rds_sg" {
  name        = "terraform_rds_sg"
  description = "Allow Postgres access"
  vpc_id      = data.aws_vpc.default.id

  # Allow access to port 5432 (Postgres) from ANYWHERE (For Lab Only!)
  # In a real job, you would restrict this to your specific IP address.
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Create the Postgres Database
resource "aws_db_instance" "metadata_db" {
  identifier           = "data-quality-db"
  allocated_storage    = 20    # 20 GB (Free tier eligible)
  engine               = "postgres"
  engine_version       = "16.3" # Latest stable version
  instance_class       = "db.t3.micro" # Free tier eligible
  
  db_name              = "metadata_db"
  username             = "postgres"
  password             = "MyStrongPassword123!" # In real life, use variables!
  
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = true # Allows you to connect from your laptop
  
  # CRITICAL FOR LABS: Skip backup when deleting
  # If you don't set this, 'terraform destroy' will hang for 20 mins trying to backup.
  skip_final_snapshot    = true 
}

# 4. Output the connection endpoint
output "db_endpoint" {
  value = aws_db_instance.metadata_db.endpoint
}