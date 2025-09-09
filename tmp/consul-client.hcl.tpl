server = false
data_dir = "/opt/consul/data"
node_name = "${node_name}"
retry_join = ["${consul_server}"]
bind_addr = "{{ GetInterfaceIP \"eth0\" }}"
advertise_addr = "{{ GetInterfaceIP \"eth0\" }}"

# Uncomment and set the license path if you have a Consul Enterprise license
# license_path = "/etc/consul.d/license.hclic"

ports {
  grpc = 8502
}

acl {
  enabled = false
}

connect {
  enabled = true
}
