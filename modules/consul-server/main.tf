resource "null_resource" "consul_server" {
  connection {
    type     = "ssh"
    host     = var.server_ip
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
      "sudo chown -R consul:consul /opt/consul /etc/consul.d /var/lib/consul /run/consul"
    ]
  }

  # Download and install Consul Enterprise
  provisioner "remote-exec" {
    inline = [
      "cd /tmp",
      "sudo wget https://releases.hashicorp.com/consul/${var.consul_version}/consul_${var.consul_version}_linux_amd64.zip",
      "sudo yum install -y unzip wget || sudo dnf install -y unzip wget || sudo apt-get update && sudo apt-get install -y unzip wget",
      "sudo unzip -o consul_${var.consul_version}_linux_amd64.zip",
      "sudo mv consul /usr/local/bin/",
      "sudo chmod +x /usr/local/bin/consul",
      "sudo restorecon /usr/local/bin/consul", # For SELinux systems, SELinux is in Enforcing mode and the consul binary has an incorrect SELinux context (user_tmp_t). This prevents systemd from executing it.
      "sudo rm consul_${var.consul_version}_linux_amd64.zip"
    ]
  }

  # Download and install Envoy
  provisioner "remote-exec" {
    inline = [
      "cd /tmp",
      "sudo wget https://releases.hashicorp.com/envoy/${var.envoy_version}/envoy_${var.envoy_version}_linux_amd64.zip",
      "sudo unzip -o envoy_${var.envoy_version}_linux_amd64.zip",
      "sudo mv envoy /usr/local/bin/",
      "sudo chmod +x /usr/local/bin/envoy",
      "sudo restorecon /usr/local/bin/envoy",
      "sudo rm envoy_${var.envoy_version}_linux_amd64.zip"
    ]
  }

  # Upload Consul server configuration
  provisioner "file" {
    content = templatefile("${path.module}/templates/consul-server.hcl.tpl", {
      server_ip = var.server_ip
      node_name = var.node_name
    })
    destination = "/tmp/consul.hcl"
  }

  # Upload systemd service file
  provisioner "file" {
    source      = "${path.module}/templates/consul.service"
    destination = "/tmp/consul.service"
  }

  # Upload license file if provided
  provisioner "file" {
    content     = var.consul_license != "" ? var.consul_license : "# No license provided"
    destination = "/tmp/license.hclic"
  }

  # Move files to correct locations and start services
  provisioner "remote-exec" {
    inline = var.consul_license != "" ? [
      "sudo mv /tmp/consul.hcl /etc/consul.d/consul.hcl",
      "sudo chown consul:consul /etc/consul.d/consul.hcl",
      "sudo mv /tmp/consul.service /etc/systemd/system/consul.service",
      "sudo chown root:root /etc/systemd/system/consul.service",
      "sudo chmod 644 /etc/systemd/system/consul.service",
      "sudo mv /tmp/license.hclic /etc/consul.d/license.hclic",
      "sudo chown consul:consul /etc/consul.d/license.hclic",
      "sudo restorecon /etc/systemd/system/consul.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable consul",
      "sudo systemctl start consul"
      ] : [
      "sudo mv /tmp/consul.hcl /etc/consul.d/consul.hcl",
      "sudo chown consul:consul /etc/consul.d/consul.hcl",
      "sudo mv /tmp/consul.service /etc/systemd/system/consul.service",
      "sleep 10", # Adding a short sleep to ensure file system consistency
      "sudo systemctl daemon-reload",
      "sudo systemctl enable consul",
      "sudo systemctl start consul"
    ]
  }

}
