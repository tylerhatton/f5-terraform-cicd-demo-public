terraform {
  required_version = ">= 0.13.5"

  required_providers {
    aws      = ">= 2.3"
    random   = ">= 2.3"
    template = ">= 2.1"
    null     = ">= 3.0"
  }
}