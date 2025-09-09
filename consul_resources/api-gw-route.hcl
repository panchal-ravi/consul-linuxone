Kind = "http-route"
Name = "web-http-route"

// Rules define how requests will be routed
Rules = [
  {
    Matches = [
      {
        Path = {
          Match = "prefix"
          Value = "/"
        }
      }
    ]
    Services = [
      {
        Name = "web"
      }
    ]
  }
]

Parents = [
  {
    Kind = "api-gateway"
    Name = "api-gateway"
    SectionName = "api-gw-listener"
  }
]
