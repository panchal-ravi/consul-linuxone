server = true
data_dir = "/opt/consul/data"
node_name = "server-1"
retry_join = ["${server_ip}"]
bind_addr = "{{ GetInterfaceIP \"eth0\" }}"
advertise_addr = "{{ GetInterfaceIP \"eth0\" }}"

# Uncomment and set the license path if you have a Consul Enterprise license
# license_path = "/etc/consul.d/license.hclic"

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
