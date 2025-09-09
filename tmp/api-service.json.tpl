{
  "service": {
    "name": "api",
    "port": 9091,
    "connect": {
      "sidecar_service": {}
    },
    "check": {
      "http": "http://localhost:9091/health",
      "interval": "10s"
    }
  }
}
