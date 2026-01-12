# Architecture Overview

Two-site homelab connected via Tailscale mesh VPN.

## Topology

```
┌─────────────────────────────────────┐     ┌─────────────────────────────────┐
│           ARPIGESH (Primary)        │     │       MALATI (Remote)           │
│                                     │     │                                 │
│  ┌─────────────────────────────┐    │     │  ┌───────────────────────────┐  │
│  │   DeskPi Super6C Cluster    │    │     │  │   Raspberry Pi 5          │  │
│  │   6x Raspberry Pi CM4       │    │     │  │   hostname: malati-pi     │  │
│  │   (details TBD)             │    │     │  │                           │  │
│  └─────────────────────────────┘    │     │  │   - Home Assistant :8123  │  │
│                                     │     │  │   - Portainer :9443       │  │
│  ┌─────────────────────────────┐    │     │  │   - Tailscale (SSH)       │  │
│  │   Standalone CM4            │    │     │  │   - Cloudflared           │  │
│  │   hostname: home            │    │     │  └───────────────────────────┘  │
│  │                             │    │     │                                 │
│  │   - Homebridge              │    │     │                                 │
│  │   - Tailscale               │    │     │                                 │
│  └─────────────────────────────┘    │     │                                 │
│                                     │     │                                 │
└──────────────┬──────────────────────┘     └────────────────┬────────────────┘
               │                                             │
               └──────────────── Tailscale ──────────────────┘
                              (MagicDNS)
```

## Network Access

| Method | Pattern | Use Case |
|--------|---------|----------|
| Tailscale MagicDNS | `<hostname>` | Primary access |
| Tailscale FQDN | `<hostname>.<tailnet>.ts.net` | Explicit/scripting |
| Local mDNS | `<hostname>.local` | Same LAN only |

## Sites

- [Arpigesh](sites/arpigesh.md) - Primary site, home
- [Malati](sites/malati.md) - Remote site, parents' home
