variable "rest_api_name" {
    type        = string
    description = "Name of the API Gateway created"
    default     = "crc-api-gateway"
}

variable "lambda_function_name" {
    type        = string
    description = "The name of the Lambda function"
}

variable "lambda_function_arn" {
    type        = string
    description = "The ARN of the Lambda function"
}

variable "rest_api_stage_name" {
    type        = string
    description = "The name of the API Gateway stage"
    default     = "deploy"
}

variable "api_gateway_region" {
    type        = string
    description = "The region in which to create/manage resources"
    default     = "us-east-1"
}

variable "api_subdomain" {
    type        = string
    description = "Name of the API Subdomain"
}