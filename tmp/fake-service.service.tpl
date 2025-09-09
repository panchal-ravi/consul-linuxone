[Unit]
Description=fake-service
After=network.target
Requires=consul.service
After=consul.service

[Service]
Type=simple
ExecStart=/opt/myapp/fake-service
User=ubuntu
EnvironmentFile=/opt/myapp/fake-service.config
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
