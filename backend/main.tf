module "lambda_function" {
  source = "./modules/lambda_function"
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
  lambda_rewrite_function_arn = module.lambda_function.rewrite_urls_arn

  depends_on = [
    module.lambda_function
  ]
}