data "aws_route53_zone" "root_domain" {
    name = var.root_domain
    private_zone = false
}

# ACM CERTIFICATE

resource "aws_acm_certificate" "cert" {
    domain_name = var.root_domain
    subject_alternative_names = ["*.${var.root_domain}"]
    validation_method = "DNS"
    lifecycle {
        create_before_destroy = true
    }
}

# ACM CERTIFICATE VALIDATION

resource "aws_route53_record" "cert_valid" {
    allow_overwrite = true
    name            =  tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
    records         = [tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value]
    type            = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
    zone_id         = data.aws_route53_zone.root_domain.zone_id
    ttl             = 60
}

resource "aws_acm_certificate_validation" "cert_validate" {
    certificate_arn         = aws_acm_certificate.cert.arn
    validation_record_fqdns = [aws_route53_record.cert_valid.fqdn]
}

# CLOUDFRONT ORIGIN ACCESS CONTROL

resource "aws_cloudfront_origin_access_control" "oac" {
    name                              = "OAC for S3 buckets"
    description                       = ""
    origin_access_control_origin_type = "s3"
    signing_behavior                  = "always"
    signing_protocol                  = "sigv4"
}

# CLOUDFRONT FUNCTION TO REWRITE CLEAN URL

resource "aws_cloudfront_function" "rewrite_html" {
    name    = "rewrite-html-extension"
    runtime = "cloudfront-js-1.0"
    comment = "Rewrites clean URLs to .html but allows .html links to work"

    code = <<-EOF
        function handler(event) {
            var request = event.request;
            var uri = request.uri;
            
            // If the URI has no file extension, append .html
            if (!uri.includes('.') && uri !== '/') {
                request.uri += '.html';
            }

            return request;
        }
    EOF
}

# CLOUDFRONT FUNCTION TO REDIRECT HTML

resource "aws_cloudfront_function" "redirect_html" {
    name    = "redirect-html-to-clean-url"
    runtime = "cloudfront-js-1.0"
    comment = "Redirects .html URLs to clean URLs"

    code = <<-EOF
        function handler(event) {
            var request = event.request;

            // If URL ends with .html, redirect to clean version
            if (request.uri.endsWith(".html")) {
                var cleanUri = request.uri.replace(/\\.html$/, "");
                return {
                    statusCode: 301,
                    statusDescription: "Moved Permanently",
                    headers: {
                        location: { value: cleanUri },
                        "cache-control": { value: "no-store" },
                        "content-type": { value: "text/html; charset=UTF-8" }
                    }
                };
            }

            return request;
        }
    EOF
}

# ROOT DOMAIN S3 BUCKET

resource "aws_s3_bucket" "root_domain" {
    bucket = var.root_domain
}

resource "aws_s3_bucket_website_configuration" "root" {
    bucket = aws_s3_bucket.root_domain.id

    redirect_all_requests_to {
        host_name = var.subdomain
        protocol = "https"
    }
}

resource "aws_s3_bucket_acl" "root_acl" {
    bucket = aws_s3_bucket.root_domain.id
    acl = "public-read"
}

# CLOUDFRONT DISTRIBUTION FOR ROOT DOMAIN S3 BUCKET

resource "aws_cloudfront_distribution" "root_s3_distribution" {
    enabled = true
    is_ipv6_enabled = true
    aliases = ["${var.root_domain}"]
    
    origin {
        domain_name = "${var.root_domain}.s3-website-${var.region}.amazonaws.com"
        origin_id = aws_s3_bucket.root_domain.bucket_regional_domain_name

        custom_origin_config {
            http_port = 80
            https_port = 443
            origin_protocol_policy = "http-only"
            origin_ssl_protocols = ["TLSv1.2"]

        }
    }

    default_cache_behavior {
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
        target_origin_id = aws_s3_bucket.root_domain.bucket_regional_domain_name
        viewer_protocol_policy = "redirect-to-https"
    } 

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    viewer_certificate {
        acm_certificate_arn = aws_acm_certificate.cert.arn
        ssl_support_method = "sni-only"
        minimum_protocol_version = "TLSv1.2_2021"
    }
}

# ROOT DOMAIN ROUTE 53 IPV4 AND IPV6 RECORDS

resource "aws_route53_record" "ipv4" {
    zone_id = data.aws_route53_zone.root_domain.zone_id
    name = var.root_domain
    type  = "A"

    alias {
        name = aws_cloudfront_distribution.root_s3_distribution.domain_name
        zone_id = aws_cloudfront_distribution.root_s3_distribution.hosted_zone_id
        evaluate_target_health = true
    }
}

resource "aws_route53_record" "ipv6" {
    zone_id = data.aws_route53_zone.root_domain.zone_id
    name = var.root_domain
    type  = "AAAA"

    alias {
        name = aws_cloudfront_distribution.root_s3_distribution.domain_name
        zone_id = aws_cloudfront_distribution.root_s3_distribution.hosted_zone_id
        evaluate_target_health = true
    }
}

#SUBDOMAIN S3 BUCKET

resource "aws_s3_bucket" "subdomain" {
    bucket = var.subdomain
}

resource "aws_s3_bucket_acl" "sub_acl" {
    bucket = aws_s3_bucket.subdomain.id
    acl = "public-read"
}

resource "aws_s3_bucket_policy" "sub_s3" {
    bucket = aws_s3_bucket.subdomain.id
    policy = data.aws_iam_policy_document.sub_s3_policy.json
}

data "aws_iam_policy_document" "sub_s3_policy" {
    statement {
        sid = "AllowCloudFrontServicePrincipal"
        effect = "Allow"
        principals {
            type = "Service"
            identifiers = ["cloudfront.amazonaws.com"]
        }
        actions = ["s3:GetObject"]
        resources = ["${aws_s3_bucket.subdomain.arn}/*"]

        condition {
            test = "StringEquals"
            variable = "AWS:SourceArn"
            values = ["${aws_cloudfront_distribution.sub_s3_distribution.arn}"]
        }
    }
}

# CLOUDFRONT DISTRIBUTION FOR WWW SUBDOMAIN S3 BUCKET

resource "aws_cloudfront_distribution" "sub_s3_distribution" {
    enabled = true
    is_ipv6_enabled = true
    aliases = ["${var.subdomain}"]
    default_root_object = "index.html"

    origin {
        domain_name = aws_s3_bucket.subdomain.bucket_regional_domain_name
        origin_id = aws_s3_bucket.subdomain.bucket_regional_domain_name

        origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    }

    default_cache_behavior {
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
        target_origin_id = aws_s3_bucket.subdomain.bucket_regional_domain_name
        viewer_protocol_policy = "redirect-to-https"

        # Rewrites clean URLs to .html (when user types "/resume")
        function_association {
            event_type   = "viewer-request"
            function_arn = aws_cloudfront_function.rewrite_html.arn
        }

        # Redirects ".html" links to clean URLs (when clicking "resume.html")
        # function_association {
            # event_type   = "viewer-request"
            # function_arn = aws_cloudfront_function.redirect_html.arn
        # }
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    viewer_certificate {
        acm_certificate_arn = aws_acm_certificate.cert.arn
        ssl_support_method = "sni-only"
        minimum_protocol_version = "TLSv1.2_2021"
    }
}

# SUBDOMAIN ROUTE 53 IPV4 AND IPV6 RECORDS

resource "aws_route53_record" "www_ipv4" {
    zone_id = data.aws_route53_zone.root_domain.zone_id
    name = var.subdomain
    type  = "A"

    alias {
        name = aws_cloudfront_distribution.sub_s3_distribution.domain_name
        zone_id = aws_cloudfront_distribution.sub_s3_distribution.hosted_zone_id
        evaluate_target_health = true
    }
}

resource "aws_route53_record" "www_ipv6" {
    zone_id = data.aws_route53_zone.root_domain.zone_id
    name = var.subdomain
    type  = "AAAA"

    alias {
        name = aws_cloudfront_distribution.sub_s3_distribution.domain_name
        zone_id = aws_cloudfront_distribution.sub_s3_distribution.hosted_zone_id
        evaluate_target_health = true
    }
}

# API SUBDOMAIN

resource "aws_api_gateway_domain_name" "api_domain_name" {
    certificate_arn = aws_acm_certificate_validation.cert_validate.certificate_arn
    domain_name     = var.api_subdomain
}

# API ROUTE 53 IPV4 AND IPV6 RECORDS

resource "aws_route53_record" "api_ipv4" {
    name    = var.api_subdomain
    type    = "A"
    zone_id = data.aws_route53_zone.root_domain.zone_id

    alias {
        evaluate_target_health = true
        name                   = aws_api_gateway_domain_name.api_domain_name.cloudfront_domain_name
        zone_id                = aws_api_gateway_domain_name.api_domain_name.cloudfront_zone_id
    }
}

resource "aws_route53_record" "api_ipv6" {
    name    = var.api_subdomain
    type    = "AAAA"
    zone_id = data.aws_route53_zone.root_domain.zone_id

    alias {
        evaluate_target_health = true
        name                   = aws_api_gateway_domain_name.api_domain_name.cloudfront_domain_name
        zone_id                = aws_api_gateway_domain_name.api_domain_name.cloudfront_zone_id
    }
}