[Unit]
Description=Start envoy proxy for ${service_name}
Requires=fake-service.service
After=fake-service.service

[Service]
Type=simple
ExecStart=/usr/local/bin/consul connect envoy -ignore-envoy-compatibility=true  --sidecar-for db -admin-bind localhost:19000
EnvironmentFile=/opt/myapp/fake-service-envoy.config

[Install]
WantedBy=multi-user.target
