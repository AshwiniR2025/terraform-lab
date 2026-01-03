# 1. Create the S3 Bucket with a custom name
resource "aws_s3_bucket" "data_lake" {
  # CHANGE THIS VALUE below to something unique!
  bucket = "ashwini-terraform-lab-bucket-2026" 
  
  force_destroy = true 

  tags = {
    Name        = "My Data Lake"
    Environment = "Dev"
  }
}

# 2. Enable Versioning
resource "aws_s3_bucket_versioning" "data_lake_ver" {
  bucket = aws_s3_bucket.data_lake.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 3. Output the bucket name
output "s3_bucket_name" {
  value = aws_s3_bucket.data_lake.id
}