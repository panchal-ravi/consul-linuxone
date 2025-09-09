[Unit]
Description=Start envoy proxy for ${service_name}
Requires=consul.service
After=consul.service

[Service]
Type=simple
ExecStart=/usr/local/bin/consul connect envoy -gateway ${gateway_type} -register -service ${service_name} -admin-bind localhost:19000
EnvironmentFile=/opt/myapp/gateway-envoy.config

[Install]
WantedBy=multi-user.target
