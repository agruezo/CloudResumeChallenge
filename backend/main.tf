# module "lambda_function" {
  # source = "./modules/lambda_function"
# }

module "lambda_function" {
  source                = "./modules/lambda_function"
  lambda_function_name  = var.lambda_function_name # Pass lambda function name
  rewrite_urls_name     = var.rewrite_urls_name  # Pass the rewrite function name
  s3_bucket_name        = var.s3_bucket_name # Pass s3 bucket name
}

module "api_gateway" {
  source               = "./modules/api_gateway"
  lambda_function_name = module.lambda_function.lambda_function_name
  lambda_function_arn  = module.lambda_function.lambda_function_arn
  api_subdomain        = module.domain_cloudfront.api_subdomain

  depends_on = [
    module.lambda_function,
    module.domain_cloudfront
  ]
}

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "domain_cloudfront" {
  source = "./modules/domain_cloudfront"
}