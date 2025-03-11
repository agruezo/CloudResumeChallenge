output "lambda_function_arn" {
    value = aws_lambda_function.lambda_function.invoke_arn
}

output "lambda_function_name" {
    value = aws_lambda_function.lambda_function.function_name
}

# Add
output "rewrite_urls_arn" {
    value = aws_lambda_function.rewrite_urls.invoke_arn
    description = "Invoke ARN of the rewrite URLs Lambda function"
}

# Add
output "rewrite_urls_name" {
    value = aws_lambda_function.rewrite_urls.function_name
    description = "Name of the rewrite URLs Lambda function"
}