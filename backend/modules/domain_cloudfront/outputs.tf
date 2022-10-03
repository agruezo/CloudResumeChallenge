output "api_subdomain" {
    value = aws_api_gateway_domain_name.api_domain_name.domain_name
}