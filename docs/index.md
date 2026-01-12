# Homelab Documentation

## Quick Access

| Site | Host | Services | Access |
|------|------|----------|--------|
| Arpigesh | `home` | Homebridge | `home.tail<TAB>` |
| Arpigesh | cluster | TBD | TBD |
| Malati | `malati-pi` | Home Assistant, Portainer | `malati-pi.tail<TAB>` |

## Documentation

### Sites
- [Architecture Overview](architecture.md) - Multi-site topology
- [Arpigesh](sites/arpigesh.md) - Primary site (home)
- [Malati](sites/malati.md) - Remote site (parents)

### Runbooks
- [Ansible Playbooks](runbooks/ansible-playbooks.md) - Configuration management
- [Bootstrap](runbooks/bootstrap.md) - New host setup

### Reference
- [Tailscale](reference/tailscale.md) - Mesh VPN, serve config
- [Cloudflare](reference/cloudflare.md) - DNS, Terraform
