provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

terraform {
  cloud {
    organization = "mrugesh"
    workspaces {
      name = "tfws-ops-cloudflare"
    }
  }
}

# Define the Zones in the Cloudflare account
# The entries here are rarely changed.

resource "cloudflare_zone" "mrugesh-net" {
  zone       = "mrugesh.net"
  plan       = "free"
  type       = "full"
  account_id = var.cloudflare_account_id
}
