# AWS Lambda Function with OpenTelemetry

A simple AWS Lambda function that demonstrates OpenTelemetry custom metrics integration using AWS Lambda OpenTelemetry layers. This project showcases different approaches to metric flushing in serverless environments.

## Overview

This project demonstrates how to integrate OpenTelemetry metrics with AWS Lambda using the official AWS Lambda OpenTelemetry layers. The Lambda function emits custom metrics and explores different flushing strategies:

- **Force Flush**: Explicitly flushes metrics using `forceFlush()`
- **Shutdown**: Gracefully shuts down the meter provider using `shutdown()`
- **Automatic**: Relies on the OpenTelemetry Lambda extension for automatic flushing

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   AWS Lambda    │    │ OpenTelemetry    │    │   Grafana       │
│   Function      │───▶│   Collector      │───▶│   Cloud        │
│                 │    │   (Extension)    │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Components

Project uses OpenTelemetry Lambda layers. Check [Opentelemetry Lambda](https://github.com/open-telemetry/opentelemetry-lambda?tab=readme-ov-file)
for latest versions.

- **Lambda Function**: Node.js 20.x function that creates and emits custom metrics
- **Lambda Layers**:
  - `opentelemetry-nodejs-0_16_0`: Node.js instrumentation layer
  - `opentelemetry-collector-amd64-0_17_0`: Collector extension layer
- **OpenTelemetry Collector**: Configured to receive OTLP metrics and export to Grafana Cloud
- **Grafana Cloud**: Destination for metrics visualization and analysis

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- Node.js 20.x
- Grafana Cloud account with OTLP endpoint credentials

## Deployment

### 1. Clone and Setup

```bash
git clone <repository-url>
cd otlp-lambda-example
npm install
```

### 2. Configure Variables

Copy the example variables file and update with your values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your configuration:

```hcl
aws_region = "eu-west-1"

# Grafana OTLP Configuration
grafana_otlp_endpoint = "https://otlp.grafana.com"
# These are not your Grafana Cloud credentials, you need to get them from Grafana Cloud.
grafana_otlp_username = "grafana-otlp-username"
grafana_otlp_password = "grafana-otlp-password"
```

### 3. Build Lambda Package

```bash
npm run build
```

This creates the `lambda-package.zip` file containing the compiled Lambda function.

### 4. Deploy Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

### 5. Test the Function

You can test the Lambda function using the following command:

```bash
npm run invoke
```

### 6. Results

You'll see the metrics in Grafana Cloud. Check the [test results](docs/test-results.md) for more details.

## Configuration Options

### Metric Flushing Strategies

The Lambda function supports different metric flushing strategies controlled by the `FLUSH_METRICS` environment variable:

| Strategy | Value | Description |
|----------|-------|-------------|
| Force Flush | `forceFlush` | Explicitly calls `forceFlush()` on the meter provider |
| Shutdown | `shutdown` | Gracefully shuts down the meter provider |
| Automatic | `none` (default) | Relies on OpenTelemetry Lambda extension |

To change the strategy, update the `flush_metrics` variable in your `terraform.tfvars`:

```hcl
flush_metrics = "shutdown"  # or "forceFlush" or "none"
```

### OpenTelemetry Collector Configuration

The collector is configured in `collector.yaml` and supports:

- **Receivers**: OTLP over gRPC (port 4317) and HTTP (port 4318)
- **Exporters**:
  - Debug exporter (console output for debugging)
  - OTLP HTTP exporter (Grafana Cloud)
- **Pipelines**: Metrics pipeline from OTLP receiver to exporters

## Monitoring and Troubleshooting

### CloudWatch Logs

The Lambda function creates detailed logs including:
- OpenTelemetry collector startup and configuration
- Metric creation and emission
- Flush operations and results
- Error messages and stack traces

```bash
aws logs tail  /aws/lambda/otlp-lambda-example
```

### Debug Exporter

The collector includes a debug exporter that logs all metrics to the console,
making it easy to verify what data is being processed.

## Current Issues

For detailed test results and known issues, see [Test Results](docs/test-results.md).
