server = true
datacenter = "dc1"
bootstrap_expect = 1
data_dir = "/opt/consul/data"
node_name = "${node_name}"
retry_join = ["${server_ip}"]
bind_addr = "${server_ip}"
advertise_addr = "${server_ip}"
client_addr = "0.0.0.0"
log_level = "INFO"

# advertise_addr = "{{ GetInterfaceIP \"eth0\" }}"
# bind_addr = "{{ GetInterfaceIP \"eth0\" }}"

# Uncomment and set the license path if you have a Consul Enterprise license
license_path = "/etc/consul.d/license.hclic"

ports {
  http = 8500
  grpc = 8502
}

ui_config {
  enabled = true
}

acl {
  enabled = false
}

connect {
  enabled = true
}
