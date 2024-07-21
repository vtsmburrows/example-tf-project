variable "hub" {
  description = "Hub Variables"
  type        = map(any)
  default = {
    east = {
      location = "East US"
      name     = "hub-east"
      ipspace  = "10.0.0.0/23"
      tags = {
        env   = "production"
        owner = "network"
      }
    }
  }
}
