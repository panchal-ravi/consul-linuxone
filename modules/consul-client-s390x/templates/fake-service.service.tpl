[Unit]
Description=fake-service
After=network.target
Requires=consul.service
After=consul.service

[Service]
Type=simple
ExecStart=/opt/myapp/run-fake-service.sh
EnvironmentFile=/opt/myapp/fake-service.config

[Install]
WantedBy=multi-user.target
