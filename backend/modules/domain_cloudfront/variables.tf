variable "root_domain" {
    type        = string
    description = "Name of the Root Domain"
    default     = "gruezo.com"
}

variable "subdomain" {
    type        = string
    description = "Name of the Subdomain"
    default     = "www.gruezo.com"
}

variable "region" {
    type = string
    description = "The region in which to create/manage resources"
    default = "us-east-1"
}

variable "api_subdomain" {
    type        = string
    description = "Name of the API Subdomain"
    default     = "api.gruezo.com"
}
