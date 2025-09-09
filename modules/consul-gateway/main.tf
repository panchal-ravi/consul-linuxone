resource "null_resource" "consul_client" {
  triggers = {
    always_run = timestamp()
  }

  connection {
    type     = "ssh"
    host     = var.client_ip
    user     = var.ssh_username
    password = var.ssh_password
  }

  # Create consul user and directories
  provisioner "remote-exec" {
    inline = [
      "sudo useradd --system --home /etc/consul.d --shell /bin/false consul || true",
      "sudo mkdir -p /opt/consul/{bin,data}",
      "sudo mkdir -p /etc/consul.d",
      "sudo mkdir -p /var/lib/consul",
      "sudo mkdir -p /run/consul",
      "sudo mkdir -p /opt/myapp",
      "sudo chown -R consul:consul /opt/consul /etc/consul.d /var/lib/consul /run/consul"
    ]
  }

  # Download and install Consul Enterprise
  provisioner "remote-exec" {
    inline = [
      "cd /tmp",
      "if [ ! -f /usr/local/bin/consul ]; then",
      "  sudo wget https://releases.hashicorp.com/consul/${var.consul_version}/consul_${var.consul_version}_linux_amd64.zip",
      "  sudo yum install -y unzip wget || sudo dnf install -y unzip wget || sudo apt-get update && sudo apt-get install -y unzip wget",
      "  sudo unzip -o consul_${var.consul_version}_linux_amd64.zip",
      "  sudo mv consul /usr/local/bin/",
      "  sudo chmod +x /usr/local/bin/consul",
      "  sudo restorecon /usr/local/bin/consul",
      "  sudo rm consul_${var.consul_version}_linux_amd64.zip",
      "fi"
    ]
  }

  # Download and install Envoy
  provisioner "remote-exec" {
    inline = [
      "cd /tmp",
      "if [ ! -f /usr/local/bin/envoy ]; then",
      "  sudo wget https://releases.hashicorp.com/envoy/${var.envoy_version}/envoy_${var.envoy_version}_linux_amd64.zip",
      "  sudo unzip -o envoy_${var.envoy_version}_linux_amd64.zip",
      "  sudo mv envoy /usr/local/bin/",
      "  sudo chmod +x /usr/local/bin/envoy",
      "  sudo restorecon /usr/local/bin/envoy",
      "  sudo rm envoy_${var.envoy_version}_linux_amd64.zip",
      "fi"
    ]
  }


  # Upload Consul client configuration
  provisioner "file" {
    content = templatefile("${path.module}/templates/consul-client.hcl.tpl", {
      node_name = var.node_name
      client_ip = var.client_ip
      server_ip = var.consul_server_ip
    })
    destination = "/tmp/consul.hcl"
  }

  # Upload service configurations and systemd files
  provisioner "file" {
    source      = "${path.module}/templates/consul.service"
    destination = "/tmp/consul.service"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/gateway-envoy.service.tpl", {
      service_name = var.service_name
      gateway_type = "api"
    })
    destination = "/tmp/gateway-envoy.service"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/gateway-envoy.config.tpl", {
      client_ip = var.client_ip
    })
    destination = "/tmp/gateway-envoy.config"
  }

  provisioner "file" {
    content     = var.consul_license != "" ? var.consul_license : "# No license provided"
    destination = "/tmp/license.hclic"
  }

  # Move files to correct locations and start services
  provisioner "remote-exec" {
    inline = concat([
      "for port in 8300 8301 8302 8500 8501 8502 8503 8600; do",
      "  sudo firewall-cmd --list-ports | grep -q \"$port/tcp\" || sudo firewall-cmd --permanent --add-port=$port/tcp",
      "done",
      "sudo firewall-cmd --list-ports | grep -q \"19000-22000/tcp\" || sudo firewall-cmd --permanent --add-port=19000-22000/tcp",
      "sudo firewall-cmd --reload",
      ],
      [
        "sudo mv /tmp/consul.hcl /etc/consul.d/consul.hcl",
        "sudo chown consul:consul /etc/consul.d/consul.hcl",
        "sudo mv /tmp/consul.service /etc/systemd/system/consul.service",
        "sudo mv /tmp/gateway-envoy.service /etc/systemd/system/gateway-envoy.service",
        "sudo chown root:root /etc/systemd/system/consul.service",
        "sudo chmod 644 /etc/systemd/system/consul.service",
        "sudo chown root:root /etc/systemd/system/gateway-envoy.service",
        "sudo chmod 644 /etc/systemd/system/gateway-envoy.service",
        "sudo mv /tmp/gateway-envoy.config /opt/myapp/gateway-envoy.config",
        "sudo chmod 755 /opt/myapp/",
        "sudo chown -R consul:consul /etc/consul.d /opt/myapp",
        "sudo restorecon /etc/systemd/system/consul.service",
        "sudo restorecon /etc/systemd/system/gateway-envoy.service",
        "sudo restorecon -R /opt/myapp/",
        ], var.consul_license != "" ? [
        "sudo mv /tmp/license.hclic /etc/consul.d/license.hclic",
        "sudo chown consul:consul /etc/consul.d/license.hclic"
        ] : [], [
        "sleep 10",
        "sudo systemctl daemon-reload",
        "sudo systemctl enable consul gateway-envoy",
        "sudo systemctl start consul",
        "sudo systemctl start gateway-envoy",
    ])
  }
}
