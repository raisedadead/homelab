variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API Token"
  sensitive   = true
}

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare Account ID"
  sensitive   = true
}

variable "cloudflare_zone_id_mrugesh_net" {
  type        = string
  description = "Cloudflare Zone ID for mrugesh.net"
  sensitive   = true
}
