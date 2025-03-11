variable "s3_bucket_name" {
    type        = string
    description = "S3 bucket to store Lambda function code"
    default     = "crc-api-gateway-lambda-function"
}

variable "lambda_function_name" {
    type        = string
    description = "The name of the Lambda function"
    default     = "crc-lambda-function"
}

variable "dynamodb_table" {
    type        = string
    description = "The name of the DynamoDB table"
    default     = "crc-dynamodb"
}

variable "region" {
    type = string
    description = "The region in which to create/manage resources"
    default = "us-east-1"
}