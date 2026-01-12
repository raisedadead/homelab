# Malati

Remote site (parents' home).

## Hardware

| Device | Hostname | IP | Services |
|--------|----------|-----|----------|
| Raspberry Pi 5 | `malati-pi` | `192.168.1.200` | Home Assistant, Portainer, Tailscale, Cloudflared |

## Services

### Home Assistant

- **Port**: 8123
- **Access**:
  - Tailscale: `https://malati-pi.<tailnet>.ts.net`
  - Tailscale Serve: `https://malati-pi.<tailnet>.ts.net` (port 443)
- **Container**: Docker

### Portainer

- **Port**: 9443 (HTTPS, self-signed)
- **Access**:
  - Tailscale: `https://malati-pi.<tailnet>.ts.net:9443`
  - Tailscale Serve: Uses `https+insecure://` backend
- **Container**: Docker

### Tailscale

- **Features**: SSH enabled, MagicDNS
- **Serve**: Configured for Home Assistant and Portainer

### Cloudflared

- **Purpose**: Cloudflare tunnel (backup access)

## Network

- LAN IP: `192.168.1.200`
- DNS: `home.mrugesh.net` points to LAN IP
- Tailscale: Connected to mesh

## Ansible Inventory

```yaml
# Tailscale access
malati:
  hosts:
    malati-pi:
      ansible_user: malati

# Local access (when on-site)
malati-local:
  hosts:
    malati-pi.local:
      ansible_user: malati
```

## Rebuild

1. Flash Raspberry Pi OS to SD card
2. Run bootstrap sequence: [Bootstrap Runbook](../runbooks/bootstrap.md)
3. Deploy services via Ansible playbooks 20-31
