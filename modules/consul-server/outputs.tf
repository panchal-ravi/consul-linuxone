output "server_ip" {
  description = "IP address of the Consul server"
  value       = var.server_ip
}

output "consul_ui_url" {
  description = "URL to access Consul UI"
  value       = "http://${var.server_ip}:8500"
}

output "resource_id" {
  description = "Resource ID for dependency management"
  value       = null_resource.consul_server.id
}
