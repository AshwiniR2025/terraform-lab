# 1. Zip the Python code automatically
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/python-file.py"
  output_path = "${path.module}/python.zip"
}

# 2. Create the IAM Role (The "Identity" of the Lambda)
resource "aws_iam_role" "lambda_exec_role" {
  name = "terraform_lab_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# 3. Attach a policy so the Lambda can write logs to CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 4. Create the Lambda Function
resource "aws_lambda_function" "data_processor" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "data-quality-processor"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "python-file.lambda_handler" # File name (python-file) . Function name (lambda_handler)
  runtime       = "python3.9"

  # This tells Terraform to update the function if the zip file changes
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}