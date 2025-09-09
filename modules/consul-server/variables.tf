variable "server_ip" {
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
  description = "Name for the Consul server node"
  type        = string
  default     = "server-1"
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

variable "consul_license" {
  description = "Consul Enterprise license key (optional)"
  type        = string
  default     = ""
  sensitive   = true
}
