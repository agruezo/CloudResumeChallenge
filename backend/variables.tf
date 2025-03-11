variable "region" {
  type        = string
  description = "The region in which to create/manage resources"
  default     = "us-east-1"
}

# Add
variable "lambda_function_name" {
    type        = string
    description = "The name of the Lambda function"
    default     = "rewrite-urls-lambda"
}

# Add
variable "rewrite_urls_name" {
    type        = string
    description = "The name of the rewrite URLs function"
    default     = "rewrite-urls-lambda"
}

# Add
variable "s3_bucket_name" {
    type        = string
    description = "S3 bucket to store Lambda function code"
}