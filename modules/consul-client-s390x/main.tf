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
      "  sudo wget https://releases.hashicorp.com/consul/${var.consul_version}/consul_${var.consul_version}_linux_s390x.zip",
      "  sudo yum install -y unzip wget || sudo dnf install -y unzip wget || sudo apt-get update && sudo apt-get install -y unzip wget",
      "  sudo unzip -o consul_${var.consul_version}_linux_s390x.zip",
      "  sudo mv consul /usr/local/bin/",
      "  sudo chmod +x /usr/local/bin/consul",
      "  sudo restorecon /usr/local/bin/consul",
      "  sudo rm consul_${var.consul_version}_linux_s390x.zip",
      "fi"
    ]
  }

  # Download and install Envoy
  # First upload envoy binary from local to remote, then move to /usr/local/bin
  provisioner "file" {
    source      = "${path.root}/binaries_s390x/envoy"
    destination = "/tmp/envoy"
  }

  provisioner "remote-exec" {
    inline = [
      "if [ ! -f /usr/local/bin/envoy ]; then",
      "  sudo cp /tmp/envoy /usr/local/bin/envoy",
      "  sudo chmod +x /usr/local/bin/envoy",
      "  sudo restorecon /usr/local/bin/envoy",
      "fi"
    ]
  }

  # Copy fake-service binary
  provisioner "file" {
    source      = "${path.root}/binaries_s390x/fake-service"
    destination = "/tmp/fake-service"
  }

  provisioner "remote-exec" {
    inline = [
      "if [ ! -f /opt/myapp/fake-service ]; then",
      "  sudo cp /tmp/fake-service /opt/myapp/fake-service",
      "  sudo chmod +x /opt/myapp/fake-service",
      "  sudo restorecon /opt/myapp/fake-service",
      "fi"
    ]
  }

  # Copy run-fake-service script
  provisioner "file" {
    source      = "${path.root}/binaries_s390x/run-fake-service.sh"
    destination = "/tmp/run-fake-service.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "if [ ! -f /opt/myapp/run-fake-service.sh ]; then",
      "  sudo cp /tmp/run-fake-service.sh /opt/myapp/run-fake-service.sh",
      "  sudo chmod +x /opt/myapp/run-fake-service.sh",
      "  sudo restorecon /opt/myapp/run-fake-service.sh",
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
    content     = templatefile("${path.module}/templates/fake-service.service.tpl", {})
    destination = "/tmp/fake-service.service"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/fake-service-envoy.service.tpl", {
      service_name = var.service_name
    })
    destination = "/tmp/fake-service-envoy.service"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/fake-service.config.tpl", {
      listen_address = var.client_ip
      service_name   = var.service_name
      listen_port    = var.service_port
    })
    destination = "/tmp/fake-service.config"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/fake-service-envoy.config.tpl", {
      client_ip = var.client_ip
    })
    destination = "/tmp/fake-service-envoy.config"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/service-definition.hcl.tpl", {
      service_name = var.service_name
      service_port = var.service_port
    })
    destination = "/tmp/service-definition.hcl"
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
        "sudo mv /tmp/fake-service.service /etc/systemd/system/fake-service.service",
        "sudo mv /tmp/fake-service-envoy.service /etc/systemd/system/fake-service-envoy.service",
        "sudo chown root:root /etc/systemd/system/consul.service",
        "sudo chmod 644 /etc/systemd/system/consul.service",
        "sudo chown root:root /etc/systemd/system/fake-service.service",
        "sudo chmod 644 /etc/systemd/system/fake-service.service",
        "sudo chown root:root /etc/systemd/system/fake-service-envoy.service",
        "sudo chmod 644 /etc/systemd/system/fake-service-envoy.service",
        "sudo mv /tmp/fake-service.config /opt/myapp/fake-service.config",
        "sudo mv /tmp/service-definition.hcl /etc/consul.d/service-definition.hcl",
        "sudo mv /tmp/fake-service-envoy.config /opt/myapp/fake-service-envoy.config",
        "sudo chmod 755 /opt/myapp/",
        "sudo chown -R consul:consul /etc/consul.d /opt/myapp",
        "sudo restorecon /etc/systemd/system/consul.service",
        "sudo restorecon /etc/systemd/system/fake-service.service",
        "sudo restorecon /etc/systemd/system/fake-service-envoy.service",
        "sudo restorecon -R /opt/myapp/",
        ], var.consul_license != "" ? [
        "sudo mv /tmp/license.hclic /etc/consul.d/license.hclic",
        "sudo chown consul:consul /etc/consul.d/license.hclic"
        ] : [], [
        "sleep 10",
        "sudo systemctl daemon-reload",
        "sudo systemctl enable consul fake-service fake-service-envoy",
        "sudo systemctl start consul",
        "sudo systemctl start fake-service",
        "sleep 5",
        "sudo systemctl start fake-service-envoy"
    ])
  }
}
