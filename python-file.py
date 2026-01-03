import json

def lambda_handler(event, context):
    print("--- Starting Data Quality Check ---")
    
    # 1. Get the data from the event (or use a default test record)
    record = event.get('data', {'id': 101, 'status': 'active', 'value': None})
    
    print(f"Processing Record: {record}")
    
    # 2. Simple Rule: Check if 'value' is missing
    validation_errors = []
    if record.get('value') is None:
        validation_errors.append("Error: Field 'value' cannot be empty.")
    
    # 3. Return results
    if validation_errors:
        result = {"status": "FAILED", "errors": validation_errors}
        print(f"Validation Failed: {validation_errors}")
    else:
        result = {"status": "PASSED", "message": "Data looks good."}
        print("Validation Passed.")

    return {
        'statusCode': 200,
        'body': json.dumps(result)
    }