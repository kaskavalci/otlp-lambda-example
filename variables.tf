variable "aws_region" {
  description = "AWS region to deploy the Lambda function"
  type        = string
  default     = "us-east-1"
}

variable "grafana_otlp_endpoint" {
  description = "Grafana OTLP endpoint"
  type        = string
  default     = "https://otlp.grafana.com"
}

variable "grafana_otlp_username" {
  description = "Grafana OTLP username"
  type        = string
  sensitive   = true
}

variable "grafana_otlp_password" {
  description = "Grafana OTLP password"
  type        = string
  sensitive   = true
}

variable "flush_metrics" {
  description = "Flush metrics"
  type        = string
  default     = "none" # or "shutdown" or "forceFlush"
}
