import boto3
import json
import os

def lambda_handler(event, context):
    # Initialize the Step Functions client
    step_functions = boto3.client('stepfunctions')
    
    # Get the ARN of the Step Function from the Lambda environment variable
    state_machine_arn = os.environ['STATE_MACHINE_ARN']

    # Parse input from EventBridge event
    input_data = {
        'bucket': event['detail']['bucket']['name'],
        'key': event['detail']['object']['key']
    }

    # Start the Step Function execution
    response = step_functions.start_execution(
        stateMachineArn=state_machine_arn,
        input=json.dumps(input_data)
    )

    return {
        'statusCode': 200,
        'body': json.dumps('Successfully started Step Function execution!')
    }
