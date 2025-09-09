output "consul_server_ip" {
  description = "IP address of the Consul server"
  value       = module.consul_server.server_ip
}

output "consul_client_1_ip" {
  description = "IP address of the first Consul client"
  value       = module.consul_client_1.client_ip
}

output "consul_client_2_ip" {
  description = "IP address of the second Consul client"
  value       = module.consul_client_2.client_ip
}

output "consul_ui_url" {
  description = "URL to access Consul UI"
  value       = module.consul_server.consul_ui_url
}

output "services" {
  description = "Information about deployed services"
  value = {
    web = {
      ip   = module.consul_client_1.client_ip
      port = module.consul_client_1.service_port
      name = module.consul_client_1.service_name
      node = module.consul_client_1.node_name
    }
    api = {
      ip   = module.consul_client_2.client_ip
      port = module.consul_client_2.service_port
      name = module.consul_client_2.service_name
      node = module.consul_client_2.node_name
    }
  }
}

output "setup_complete" {
  description = "Deployment status"
  value       = "Consul Service Mesh setup completed successfully"
  depends_on = [
    module.consul_server,
    module.consul_client_1,
    module.consul_client_2
  ]
}
