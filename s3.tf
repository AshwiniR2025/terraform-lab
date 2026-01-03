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

# Upload the Config files to S3 automatically
resource "aws_s3_object" "upload_configs" {
  for_each = fileset("${path.module}/configs/", "*")

  bucket = aws_s3_bucket.data_lake.id
  key    = "governance-configs/${each.value}" # Creates a folder in S3
  source = "${path.module}/configs/${each.value}"
  
  # Tracks changes to the file so Terraform updates it when you edit the YAML/JSON
  etag   = filemd5("${path.module}/configs/${each.value}")
}