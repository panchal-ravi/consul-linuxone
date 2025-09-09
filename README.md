# Consul Service Mesh Setup Guide

This guide provides detailed step-by-step instructions to set up and configure a Consul Service Mesh environment with API Gateway support across multiple architectures.

## Table of Contents

1. [Environment Preparation](#environment-preparation)
2. [Infrastructure Setup](#infrastructure-setup)
3. [Terraform Deployment](#terraform-deployment)
4. [Post-Deployment Configuration](#post-deployment-configuration)
5. [API Gateway Configuration](#api-gateway-configuration)
6. [Service Testing & Verification](#service-testing--verification)
7. [Advanced Configuration](#advanced-configuration)
8. [Troubleshooting](#troubleshooting)
9. [Maintenance & Operations](#maintenance--operations)

---

## Environment Preparation

### 1.1 Virtual Machine Requirements

Prepare 5 Linux VMs with the following specifications:

| VM | Purpose | Architecture | IP Address | Resources |
|----|---------|--------------|------------|-----------|
| consul-server | Control Plane | x86_64 | 10.3.26.11 | 2GB RAM, 10GB Disk |
| web-client | Web Service | x86_64 | 10.3.26.12 | 2GB RAM, 10GB Disk |
| api-client | API Service | x86_64 | 10.3.26.13 | 2GB RAM, 10GB Disk |
| db-client | DB Service | s390x | 10.3.26.2 | 2GB RAM, 10GB Disk |
| gateway-client | API Gateway | x86_64 | 10.3.26.14 | 2GB RAM, 10GB Disk |

### 1.2 Operating System Setup

Each VM should have:

```bash
# Update system packages
sudo yum update -y  # or apt-get update && apt-get upgrade -y

# Install required packages
sudo yum install -y wget unzip firewalld  # RHEL/CentOS
# sudo apt-get install -y wget unzip ufw  # Ubuntu/Debian

# Enable and start firewall
sudo systemctl enable firewalld
sudo systemctl start firewalld
```

### 1.3 Network Configuration

Configure firewall rules on **all VMs**:

```bash
# Essential Consul ports
sudo firewall-cmd --permanent --add-port=8300/tcp  # Server RPC
sudo firewall-cmd --permanent --add-port=8301/tcp  # Gossip TCP
sudo firewall-cmd --permanent --add-port=8301/udp  # Gossip UDP  
sudo firewall-cmd --permanent --add-port=8302/tcp  # WAN Gossip TCP
sudo firewall-cmd --permanent --add-port=8500/tcp  # HTTP API
sudo firewall-cmd --permanent --add-port=8501/tcp  # HTTPS API
sudo firewall-cmd --permanent --add-port=8502/tcp  # gRPC API
sudo firewall-cmd --permanent --add-port=8503/tcp  # gRPC TLS
sudo firewall-cmd --permanent --add-port=8600/tcp  # DNS TCP
sudo firewall-cmd --permanent --add-port=8600/udp  # DNS UDP

# Envoy proxy ports
sudo firewall-cmd --permanent --add-port=19000-22000/tcp

# Application ports
sudo firewall-cmd --permanent --add-port=9090/tcp  # fake-service
sudo firewall-cmd --permanent --add-port=8080/tcp  # API Gateway (gateway VM only)

# Reload firewall
sudo firewall-cmd --reload
```

### 1.4 SSH Configuration

Ensure SSH access is configured:

```bash
# Test SSH connectivity from your local machine
ssh username@10.3.26.11
ssh username@10.3.26.12
ssh username@10.3.26.13
ssh username_s390x@10.3.26.2
ssh username@10.3.26.14
```

### 1.5 s390x Binary Preparation

For the s390x VM, prepare the required binaries in the `binaries_s390x/` directory:

```bash
# Create directory structure
mkdir -p binaries_s390x

# Download or compile s390x binaries
# Note: These need to be obtained separately as they're architecture-specific
# Place the following files in binaries_s390x/:
# - envoy (Envoy proxy for s390x)
# - fake-service (fake-service binary for s390x)
# - run-fake-service.sh (helper script)
```

**run-fake-service.sh script example:**
```bash
#!/bin/bash
# binaries_s390x/run-fake-service.sh

export NAME="${SERVICE_NAME:-fake-service}"
export LISTEN_ADDR="${LISTEN_ADDR:-0.0.0.0:9090}"

/opt/myapp/fake-service \
  --name="${NAME}" \
  --listen-addr="${LISTEN_ADDR}" \
  --message="Hello from ${NAME} on s390x!" \
  --server-type=http
```

---

## Infrastructure Setup

### 2.1 Terraform Installation

Install Terraform on your local machine:

```bash
# Download and install Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform version
```

### 2.2 Project Configuration

Clone or set up the project structure:

```bash
# Navigate to project directory
cd /Users/ravipanchal/learn/ibm/linuxone/consul

# Create terraform.tfvars from example
cp terraform.tfvars.example terraform.tfvars
```

### 2.3 Configure Variables

Edit `terraform.tfvars` with your environment details:

```hcl
# terraform.tfvars
consul_server_ip   = "10.3.26.11"
consul_client_1_ip = "10.3.26.12"
consul_client_2_ip = "10.3.26.13"
consul_client_3_ip = "10.3.26.2"
consul_client_4_ip = "10.3.26.14"

# SSH credentials for x86_64 VMs
ssh_username = "your_username"
ssh_password = "your_password"

# SSH credentials for s390x VM (if different)
ssh_username_s390x = "your_s390x_username"  
ssh_password_s390x = "your_s390x_password"

# Optional: Consul Enterprise license
consul_license = "your_consul_enterprise_license_key"

# Optional: Version overrides
consul_version = "1.21.4+ent"
envoy_version  = "1.33.2"
```

---

## Terraform Deployment

### 3.1 Initialize Terraform

```bash
# Initialize Terraform
terraform init
```

### 3.2 Plan Deployment

```bash
# Review planned changes
terraform plan

# Save plan for review
terraform plan -out=consul.plan
```

### 3.3 Execute Deployment

```bash
# Apply configuration
terraform apply

# Or apply from saved plan
terraform apply consul.plan
```
---

## Post-Deployment Configuration

### 4.1 Verify Consul Cluster

**On Consul Server (10.3.26.11):**

```bash
# Check Consul status
sudo systemctl status consul
consul version

# Verify cluster members
consul members

# Expected output:
# Node      Address          Status  Type    Build   Protocol  DC   Partition  Segment
# server-1  10.3.26.11:8301  alive   server  1.21.4  2         dc1  default    <all>
# client-1  10.3.26.12:8301  alive   client  1.21.4  2         dc1  default    <default>
# client-2  10.3.26.13:8301  alive   client  1.21.4  2         dc1  default    <default>
# client-3  10.3.26.2:8301   alive   client  1.21.0  2         dc1  default    <default>
# api-gateway 10.3.26.14:8301 alive  client  1.21.4  2         dc1  default    <default>

# Check registered services
consul catalog services

# Expected services:
# api
# api-gateway
# consul
# db  
# web
```

### 4.2 Verify Service Health

**Check individual services:**

```bash
# Web service (client-1)
ssh username@10.3.26.12
sudo systemctl status consul fake-service fake-service-envoy

# API service (client-2) 
ssh username@10.3.26.13
sudo systemctl status consul fake-service fake-service-envoy

# DB service (client-3)
ssh username_s390x@10.3.26.2
sudo systemctl status consul fake-service fake-service-envoy

# Gateway (client-4)
ssh username@10.3.26.14
sudo systemctl status consul gateway-envoy
```

### 4.3 Access Consul UI

Open browser and navigate to: `http://10.3.26.11:8500`

Expected UI sections:
- **Services**: Shows web, api, db, api-gateway services
- **Nodes**: Shows 5 registered nodes
---

## API Gateway Configuration

### 5.1 Configure Proxy Defaults

Apply global proxy configuration:

```bash
# SSH to Consul server
ssh username@10.3.26.11

# Apply proxy defaults
consul config write /path/to/consul_resources/proxy-defaults.hcl

# Verify configuration
consul config read -kind proxy-defaults -name global
```

**Content of proxy-defaults.hcl:**
```hcl
Kind      = "proxy-defaults"
Name      = "global"
Config {
  protocol = "http"
}
```

### 5.2 Configure API Gateway Listener

Set up the gateway listener:

```bash
# Apply gateway listener configuration
consul config write /path/to/consul_resources/api-gw-listener.hcl

# Verify configuration
consul config read -kind api-gateway -name api-gateway
```

### 5.3 Configure HTTP Routes

Set up routing rules:

```bash
# Apply HTTP route configuration
consul config write /path/to/consul_resources/api-gw-route.hcl

# Verify route configuration
consul config read -kind http-route -name web-http-route
```

---

## Service Testing & Verification

### 6.1 Direct Service Access

Test each service directly:

```bash
# Test web service (10.3.26.12)
curl http://localhost:9090
# Expected: JSON response from fake-service

# Test API service (10.3.26.13)
curl http://localhost:9090
# Expected: JSON response from fake-service

# Test DB service (10.3.26.2)
curl http://localhost:9090
# Expected: JSON response from fake-service (s390x)
```

### 6.2 API Gateway Testing

Test external access via API Gateway:

```bash
# Test gateway accessibility
curl http://10.3.26.14:8080
# Expected: Response routed to web service

# Check gateway admin interface
curl http://10.3.26.14:19000/stats
```

### 6.3 Health Check Verification

Verify service health checks:

```bash
# Check service health via Consul API
curl http://10.3.26.11:8500/v1/health/service/web
curl http://10.3.26.11:8500/v1/health/service/api
curl http://10.3.26.11:8500/v1/health/service/db

# Check Envoy cluster health
ssh username@10.3.26.12
curl http://localhost:19000/clusters
```
---

## Troubleshooting

### 7.1 Common Issues

**Issue: Consul agents not joining cluster**

```bash
# Check network connectivity
ping 10.3.26.11

# Verify firewall ports
sudo firewall-cmd --list-ports

# Check Consul logs
journalctl -u consul -f --no-pager

# Manually join cluster if needed
consul join 10.3.26.11
```

**Issue: Services not registering**

```bash
# Check service definition files
ls -la /etc/consul.d/
cat /etc/consul.d/service-definition.hcl

# Restart Consul agent
sudo systemctl restart consul

# Check service registration
consul services register /etc/consul.d/service-definition.hcl
```

**Issue: Envoy proxy not starting**

```bash
# Check Envoy configuration
cat /opt/myapp/fake-service-envoy.config

# Verify Envoy binary
/usr/local/bin/envoy --version

# Check proxy logs
journalctl -u fake-service-envoy -f --no-pager

# Manual proxy bootstrap
consul connect envoy -sidecar-for web
```

### 7.2 Log Analysis

**Consul Agent Logs:**
```bash
# Real-time logs
journalctl -u consul -f --no-pager

# Recent errors
journalctl -u consul --since "1 hour ago" | grep ERROR

# Specific log level
consul monitor -log-level=DEBUG
```

**Application Service Logs:**
```bash
# fake-service logs
journalctl -u fake-service -f --no-pager

# Service startup issues
systemctl status fake-service -l
```

**Envoy Proxy Logs:**
```bash
# Envoy access logs
journalctl -u fake-service-envoy -f --no-pager

# Envoy admin interface
curl localhost:19000/stats | grep error
curl localhost:19000/clusters
```

### 7.3 Network Diagnostics

```bash
# Test Consul ports
telnet 10.3.26.11 8500
telnet 10.3.26.11 8301

# Check DNS resolution
nslookup web.service.consul 127.0.0.1:8600
dig @127.0.0.1 -p 8600 web.service.consul

# Verify proxy connectivity  
curl -v localhost:20000/health
```

