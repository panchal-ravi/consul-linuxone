variable "consul_server_ip" {
  description = "IP address of the Consul server"
  type        = string
  default     = "10.3.26.11"
}

variable "consul_client_1_ip" {
  description = "IP address of the first Consul client"
  type        = string
  default     = "10.3.26.12"
}

variable "consul_client_2_ip" {
  description = "IP address of the second Consul client"
  type        = string
  default     = "10.3.26.13"
}

variable "consul_client_3_ip" {
  description = "IP address of the third Consul client"
  type        = string
  default     = "10.3.26.2"
}

variable "consul_client_4_ip" {
  description = "IP address of the fourth Consul client"
  type        = string
  default     = "10.3.26.14"
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

variable "ssh_username_s390x" {
  description = "SSH username for VM access"
  type        = string
  sensitive   = true
}

variable "ssh_password_s390x" {
  description = "SSH password for VM access"
  type        = string
  sensitive   = true
}

variable "consul_license" {
  description = "Consul Enterprise license key (optional)"
  type        = string
  default     = ""
  sensitive   = true
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
