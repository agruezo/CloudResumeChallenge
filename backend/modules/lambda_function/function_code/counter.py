import boto3

dynamodb=boto3.resource("dynamodb")
table=dynamodb.Table("crc-dynamodb")

def lambda_handler(event, context):
    
    response = table.get_item(
        Key={
        'id': 1
        }
    )
    visitor_count = response['Item']['visitor']
    visitor_count += 1
    
    response = table.put_item(
        Item = {
            'id': 1,
            'visitor': visitor_count
        }
    )
    
    return {
        "statusCode": 200,
        "headers": {
			"Content-Type": "application/json",
			"Access-Control-Allow-Headers": "Content-Type",
			"Access-Control-Allow-Origin": "*",
			"Access-Control-Allow-Methods": "OPTIONS,GET",
		},
        "body": visitor_count
    }
