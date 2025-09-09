
service {
  name = "${service_name}"
  port = ${service_port}

  connect {
    sidecar_service {
    %{ if service_name == "web" }
      proxy {
        upstreams = [{
          destination_name = "api"
          local_bind_address = "127.0.0.1"
          local_bind_port  = 8181
        }]
      }
    %{ endif }
    }
  }

  check {
    http = "http://localhost:${service_port}/health",
    interval = "10s"
  }
}

