LISTEN_ADDR=127.0.0.1:${listen_port}
NAME=${service_name}
MESSAGE="Hello from ${service_name} service"
%{ if service_name == "web" || service_name == "api" }
UPSTREAM_URIS=127.0.0.1:8181
%{ endif }