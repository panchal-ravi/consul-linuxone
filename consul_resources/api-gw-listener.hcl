Kind = "api-gateway"
Name = "api-gateway"

// Each listener configures a port which can be used to access the Consul cluster
Listeners = [
    {
        Port = 8080
        Name = "api-gw-listener"
        Protocol = "http"
    }
]