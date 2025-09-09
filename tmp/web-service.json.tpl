{
  "service": {
    "name": "web",
    "port": 9090,
    "connect": {
      "sidecar_service": {}
    },
    "check": {
      "http": "http://localhost:9090/health",
      "interval": "10s"
    }
  }
}
