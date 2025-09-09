variable "client_ip" {
  description = "IP address of the Consul client"
  type        = string
}

variable "consul_server_ip" {
  description = "IP address of the Consul server"
  type        = string
}

variable "ssh_username" {
  description = "SSH username for VM access"
  type        = string
  sensitive   = true
}

variable "ssh_password" {
  description = "SSH password for VM access"
  type        = string
  sensitive   = true
}

variable "node_name" {
  description = "Name for the Consul client node"
  type        = string
}

variable "service_name" {
  description = "Name of the service to run on this client"
  type        = string
}

variable "service_port" {
  description = "Port for the service to listen on"
  type        = string
}

variable "consul_version" {
  description = "Version of Consul to install"
  type        = string
  default     = "1.21.4+ent"
}

variable "envoy_version" {
  description = "Version of Envoy to install"
  type        = string
  default     = "1.33.2"
}

variable "fake_service_version" {
  description = "Version of fake-service to install"
  type        = string
  default     = "v0.26.2"
}

variable "consul_license" {
  description = "Consul Enterprise license key (optional)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "server_dependency" {
  description = "Dependency on server resource to ensure proper ordering"
  type        = string
  default     = ""
}
