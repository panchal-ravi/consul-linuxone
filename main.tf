terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Consul Server
module "consul_server" {
  source = "./modules/consul-server"

  server_ip      = var.consul_server_ip
  ssh_username   = var.ssh_username
  ssh_password   = var.ssh_password
  node_name      = "server-1"
  consul_version = var.consul_version
  envoy_version  = var.envoy_version
  consul_license = var.consul_license
}

# Consul Client VM 1 - Web Service
module "consul_client_1" {
  source = "./modules/consul-client"

  client_ip         = var.consul_client_1_ip
  consul_server_ip  = var.consul_server_ip
  ssh_username      = var.ssh_username
  ssh_password      = var.ssh_password
  node_name         = "client-1"
  service_name      = "web"
  service_port      = "9090"
  consul_version    = var.consul_version
  envoy_version     = var.envoy_version
  consul_license    = var.consul_license
  server_dependency = module.consul_server.resource_id
}

# Consul Client VM 2 - API Service
module "consul_client_2" {
  source = "./modules/consul-client"

  client_ip         = var.consul_client_2_ip
  consul_server_ip  = var.consul_server_ip
  ssh_username      = var.ssh_username
  ssh_password      = var.ssh_password
  node_name         = "client-2"
  service_name      = "api"
  service_port      = "9090"
  consul_version    = var.consul_version
  envoy_version     = var.envoy_version
  consul_license    = var.consul_license
  server_dependency = module.consul_server.resource_id
}

# Consul Client VM 3 - DB Service
module "consul_client_3" {
  source = "./modules/consul-client-s390x"

  client_ip         = var.consul_client_3_ip
  consul_server_ip  = var.consul_server_ip
  ssh_username      = var.ssh_username_s390x
  ssh_password      = var.ssh_password_s390x
  node_name         = "client-3"
  service_name      = "db"
  service_port      = "9090"
  consul_version    = "1.21.0-rc2+ent"
  envoy_version     = var.envoy_version
  consul_license    = var.consul_license
  server_dependency = module.consul_server.resource_id
}

# Consul Client VM 4 - Gateway API Service
module "consul_client_4" {
  source = "./modules/consul-gateway"

  client_ip         = var.consul_client_4_ip
  consul_server_ip  = var.consul_server_ip
  ssh_username      = var.ssh_username
  ssh_password      = var.ssh_password
  node_name         = "api-gateway"
  service_name      = "api-gateway"
  service_port      = "9090"
  consul_version    = var.consul_version
  envoy_version     = var.envoy_version
  consul_license    = var.consul_license
  server_dependency = module.consul_server.resource_id
}
