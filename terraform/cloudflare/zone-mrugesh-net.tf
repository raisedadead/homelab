resource "cloudflare_record" "root-a" {
  name    = "mrugesh.net"
  proxied = true
  ttl     = 1
  type    = "A"
  content = "192.0.2.1"
  zone_id = var.cloudflare_zone_id_mrugesh_net
}

resource "cloudflare_record" "www-cname-mrugesh-net" {
  name    = "www"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  content = "mrugesh.net"
  zone_id = var.cloudflare_zone_id_mrugesh_net
}

resource "cloudflare_record" "dmarc-txt" {
  name    = "_dmarc"
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "v=DMARC1; p=reject; rua=mailto:noreply@mrugesh.net"
  zone_id = var.cloudflare_zone_id_mrugesh_net
}

resource "cloudflare_record" "spf-txt" {
  name    = "mrugesh.net"
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "v=spf1 -all"
  zone_id = var.cloudflare_zone_id_mrugesh_net
}

# Add records below ----------------------------------------------

resource "cloudflare_record" "kendra_on_2" {
  name    = "kendra.lan.mrugesh.net"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.0.25"
  zone_id = var.cloudflare_zone_id_mrugesh_net
}
