output "client_ip" {
  description = "IP address of the Consul client"
  value       = var.client_ip
}

output "service_name" {
  description = "Name of the service running on this client"
  value       = var.service_name
}

output "service_port" {
  description = "Port of the service running on this client"
  value       = var.service_port
}

output "node_name" {
  description = "Node name of the Consul client"
  value       = var.node_name
}

output "resource_id" {
  description = "Resource ID for dependency management"
  value       = null_resource.consul_client.id
}
