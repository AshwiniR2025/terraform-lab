import json
import boto3
import yaml  # NOTE: You must add a 'PyYAML' Lambda Layer for this to work

# Initialize S3 Client
s3 = boto3.client('s3')

# CONFIGURATION
# --- CORRECTED LINE 9 BELOW ---
BUCKET_NAME = "ashwini-terraform-lab-bucket-2026" 
RULES_KEY = "governance-configs/dq_rules.yaml"

def get_rules_from_s3():
    """Fetches and parses the data quality rules from S3."""
    try:
        print(f"Fetching rules from: {BUCKET_NAME}/{RULES_KEY}")
        response = s3.get_object(Bucket=BUCKET_NAME, Key=RULES_KEY)
        rules_content = response['Body'].read().decode('utf-8')
        return yaml.safe_load(rules_content)
    except Exception as e:
        print(f"Error loading rules: {str(e)}")
        return None

def validate_record(record, rules):
    """Checks the record against the loaded rules."""
    errors = []
    
    # Loop through each rule in the YAML file
    for check in rules.get('checks', []):
        field = check['field']
        rule_type = check['rule']
        
        # Rule 1: Check for NOT_NULL
        if rule_type == "NOT_NULL":
            if record.get(field) is None:
                errors.append(f"Critical: {field} cannot be empty.")
                
        # Rule 2: Check for Range (e.g., Age)
        if rule_type == "RANGE":
            value = record.get(field)
            if value is not None:
                if not (check['min'] <= value <= check['max']):
                    errors.append(f"Range Error: {field} must be between {check['min']} and {check['max']}.")

    return errors

def lambda_handler(event, context):
    print("--- Starting Governed Data Quality Check ---")
    
    # 1. Load Rules from S3 (Governance as Code)
    rules = get_rules_from_s3()
    if not rules:
        return {'statusCode': 500, 'body': "Failed to load governance rules."}

    # 2. Get Data (For testing, we use the event or a dummy record)
    incoming_data = event.get('data', {
        "customer_id": 123,
        "first_name": "Ashwini",
        "age": 150,           # This should FAIL (Max is 120)
        "email": None         # This might fail depending on your rules
    })
    
    print(f"Processing Record: {incoming_data}")

    # 3. Validate
    validation_errors = validate_record(incoming_data, rules)

    # 4. Report Results
    if validation_errors:
        result = {"status": "FAILED", "errors": validation_errors}
        print(f"❌ DATA REJECTED: {validation_errors}")
    else:
        result = {"status": "PASSED", "message": "Data adheres to governance standards."}
        print("✅ DATA APPROVED")

    return {
        'statusCode': 200,
        'body': json.dumps(result)
    }