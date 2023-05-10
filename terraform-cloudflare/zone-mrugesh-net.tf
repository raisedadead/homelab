resource "cloudflare_record" "root-a" {
  name    = "mrugesh.net"
  proxied = true
  ttl     = 1
  type    = "A"
  value   = "192.0.2.1"
  zone_id = var.cloudflare_zone_id_mrugesh_net
}

resource "cloudflare_record" "pve-a-192-168-2-10" {
  name    = "pve"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "192.168.2.10"
  zone_id = var.cloudflare_zone_id_mrugesh_net
}

resource "cloudflare_record" "hello-a-192-168-2-100" {
  name    = "hello"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "192.168.2.100"
  zone_id = var.cloudflare_zone_id_mrugesh_net
}

resource "cloudflare_record" "www-cname-mrugesh-net" {
  name    = "www"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "mrugesh.net"
  zone_id = var.cloudflare_zone_id_mrugesh_net
}

resource "cloudflare_record" "dmarc-txt" {
  name    = "_dmarc"
  proxied = false
  ttl     = 1
  type    = "TXT"
  value   = "v=DMARC1; p=reject; rua=mailto:noreply@mrugesh.net"
  zone_id = var.cloudflare_zone_id_mrugesh_net
}

resource "cloudflare_record" "spf-txt" {
  name    = "mrugesh.net"
  proxied = false
  ttl     = 1
  type    = "TXT"
  value   = "v=spf1 -all"
  zone_id = var.cloudflare_zone_id_mrugesh_net
}

