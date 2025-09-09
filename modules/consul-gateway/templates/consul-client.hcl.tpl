server = false
datacenter = "dc1"
data_dir = "/opt/consul/data"
node_name = "${node_name}"
retry_join = ["${server_ip}"]
bind_addr = "${client_ip}"
advertise_addr = "${client_ip}"
client_addr = "0.0.0.0"
log_level = "INFO"
# bind_addr = "{{ GetInterfaceIP \"eth0\" }}"
# advertise_addr = "{{ GetInterfaceIP \"eth0\" }}"

# Uncomment and set the license path if you have a Consul Enterprise license
license_path = "/etc/consul.d/license.hclic"

ports {
  grpc = 8502
}

acl {
  enabled = false
}

connect {
  enabled = true
}
