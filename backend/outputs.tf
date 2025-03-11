output "lambda_function_arn" {
  value = module.lambda_function.lambda_function_arn
}

output "lambda_function_name" {
  value = module.lambda_function.lambda_function_name
}

# Add
output "rewrite_urls_arn" {
  value = module.rewrite_urls.rewrite_urls_arn
}

# Add
output "rewrite_urls_name" {
  value = module.rewrite_urls.rewrite_urls_name
}

output "dynamodb_table_arn" {
  value = module.dynamodb.dynamodb_table_arn
}

output "rest_api_url" {
  value = module.api_gateway.rest_api_url
}