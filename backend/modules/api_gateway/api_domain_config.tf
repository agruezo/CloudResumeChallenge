resource "aws_api_gateway_base_path_mapping" "path_mapping" {
    api_id      = aws_api_gateway_rest_api.rest_api.id
    stage_name  = aws_api_gateway_stage.rest_api_stage.stage_name
    domain_name = var.api_subdomain
}