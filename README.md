# homelab

> Infrastructure as code for my home lab.

## What is this about?

Ansible playbooks and Terraform configs managing a distributed home lab across two sites, connected via Tailscale mesh VPN.

## Tech Stack

- **Configuration Management**: [Ansible](https://www.ansible.com/) (roles-based)
- **DNS/CDN**: [Terraform](https://www.terraform.io/) + [Cloudflare](https://www.cloudflare.com/)
- **Container Orchestration**: [Docker](https://www.docker.com/) + [Portainer](https://www.portainer.io/)
- **Networking**: [Tailscale](https://tailscale.com/) (mesh VPN), [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
- **Hardware**: Raspberry Pi CM4, DeskPi Super6C cluster

## License

ISC License - see [LICENSE](./LICENSE) file for details.
