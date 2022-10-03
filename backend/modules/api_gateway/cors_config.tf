resource "aws_api_gateway_resource" "cors_resource" {
        rest_api_id = aws_api_gateway_rest_api.rest_api.id
        parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
        path_part   = "{cors+}"
}

resource "aws_api_gateway_method" "cors_method" {
    rest_api_id   = aws_api_gateway_rest_api.rest_api.id
    resource_id   = aws_api_gateway_resource.cors_resource.id
    http_method   = "OPTIONS"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors_integration" {
    rest_api_id = aws_api_gateway_rest_api.rest_api.id
    resource_id = aws_api_gateway_resource.cors_resource.id
    http_method = aws_api_gateway_method.cors_method.http_method
    type = "MOCK"
    request_templates = {
        "application/json" = jsonencode({
            statusCode=200
        })
        }
}

resource "aws_api_gateway_method_response" "cors_response" {
    depends_on = [aws_api_gateway_method.cors_method]
    rest_api_id = aws_api_gateway_rest_api.rest_api.id
    resource_id = aws_api_gateway_resource.cors_resource.id
    http_method = aws_api_gateway_method.cors_method.http_method
    status_code = 200
    response_parameters = {
        "method.response.header.Access-Control-Allow-Origin" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Headers" = true
    }
    response_models = {
        "application/json" = "Empty"
    }
}   

resource "aws_api_gateway_integration_response" "cors_integration_response" {
    depends_on = [aws_api_gateway_integration.cors_integration, aws_api_gateway_method_response.cors_response]
    rest_api_id = aws_api_gateway_rest_api.rest_api.id
    resource_id = aws_api_gateway_resource.cors_resource.id
    http_method = aws_api_gateway_method.cors_method.http_method
    status_code = 200
    response_parameters = {
        "method.response.header.Access-Control-Allow-Origin" = "'*'", 
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET, OPTIONS'" 
    }
}