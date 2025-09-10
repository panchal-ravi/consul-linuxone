Kind = "tcp-route"
Name = "web-tcp-route"

Services = [
  {
    Name = "web"
  }
]

Parents = [
  {
    Kind = "api-gateway"
    Name = "api-gateway"
    SectionName = "api-gw-listener"
  }
]
