# Tailscale Serve Configuration

Tailscale Serve provides HTTPS access to services with valid Let's Encrypt certificates via your `*.ts.net` domain.

## Services

### Home Assistant

```bash
sudo tailscale serve --service=svc:hass-m --https=443 http://localhost:8123
```

- **Backend**: `http://localhost:8123` (HTTP - no TLS)
- **Frontend**: `https://malati-pi.spitz-tegu.ts.net` (HTTPS via Tailscale)

### Portainer

```bash
sudo tailscale serve --service=svc:portainer-m --https=443 https+insecure://localhost:9443
```

- **Backend**: `https+insecure://localhost:9443` (HTTPS with self-signed cert)
- **Frontend**: `https://malati-pi.spitz-tegu.ts.net:9443` (HTTPS via Tailscale)

## Backend Protocol Reference

| Backend Type | Tailscale Serve URL | Use Case |
|--------------|---------------------|----------|
| HTTP | `http://localhost:PORT` | Service without TLS (e.g., Home Assistant) |
| HTTPS (valid cert) | `https://localhost:PORT` | Service with valid TLS cert |
| HTTPS (self-signed) | `https+insecure://localhost:PORT` | Service with self-signed cert (e.g., Portainer) |

## Management Commands

```bash
# Check status
tailscale serve status

# Reset all serve config
sudo tailscale serve reset

# Run in background
sudo tailscale serve --bg ...
```

## Notes

- Tailscale Serve handles TLS termination with valid Let's Encrypt certificates
- The `https+insecure://` prefix tells Tailscale to connect to an HTTPS backend but ignore certificate validation (for self-signed certs)
- Services are accessible only within your Tailnet (not exposed to public internet unless using Funnel)
