# Ansible Playbooks

Atomic configuration management for homelab infrastructure. Each playbook performs a single, focused task.

## Setup

```bash
cd ansible
make install
source .venv/bin/activate
```

## Playbooks

| Range | Category | Playbook | Purpose |
|-------|----------|----------|---------|
| 00-09 | Ops | `00-power` | Reboot/shutdown |
| | | `01-update` | apt update/upgrade |
| | | `02-uptime` | Check uptime |
| 10-19 | System | `10-user` | User, sudo, SSH keys, SSH hardening |
| | | `11-locale` | Locale (en_US.UTF-8) |
| | | `12-hostname` | FQDN hostname |
| 20-29 | Services | `20-docker` | Docker CE |
| | | `21-tailscale-install` | Install Tailscale |
| | | `22-tailscale-up` | Connect to tailnet (with SSH) |
| 30-39 | Apps | `30-portainer` | Portainer container |
| | | `31-homeassistant` | Home Assistant container |
| 90-99 | Platform | `90-pve-subscription` | Proxmox VE |

## Usage

```bash
# Basic
ansible-playbook play--10-user.yml -i inventory/hosts.ini -e "variable_host=malati"

# With custom GitHub users for SSH keys
ansible-playbook play--10-user.yml -i inventory/hosts.ini \
  -e "variable_host=malati" \
  -e "variable_github_users=['raisedadead','prayashm']"

# Ad-hoc inventory
ansible-playbook play--11-locale.yml \
  -i "hostname.local," \
  -e "variable_host=hostname.local ansible_user=pi"
```

## Variables

| Variable | Default | Used In |
|----------|---------|---------|
| `variable_host` | `none` | All |
| `variable_user` | `malati` | `10-user` |
| `variable_github_users` | `['raisedadead', 'prayashm']` | `10-user` |
| `variable_domain` | `lan.mrugesh.net` | `12-hostname` |
| `TAILSCALE_AUTH_KEY` | (env var) | `22-tailscale-up` |
| `variable_tailscale_tags` | `tag:services` | `22-tailscale-up` |
| `variable_tailscale_exit_node` | `false` | `22-tailscale-up` |
| `variable_tailscale_cert` | `false` | `22-tailscale-up` |

## New Host Bootstrap

For hosts not yet in inventory, create a temp inventory first:

```bash
echo -e "[bootstrap]\nhost.local ansible_user=pi ansible_password=raspberry" > /tmp/bootstrap.ini
```

Then run in order:

```bash
# 1. Setup user, SSH keys, disable password auth
ansible-playbook play--10-user.yml -i /tmp/bootstrap.ini -e "variable_host=bootstrap"

# 2. Fix locale (update temp inventory with new user)
echo -e "[bootstrap]\nhost.local ansible_user=malati" > /tmp/bootstrap.ini
ansible-playbook play--11-locale.yml -i /tmp/bootstrap.ini -e "variable_host=bootstrap"

# 3. Set hostname
ansible-playbook play--12-hostname.yml -i /tmp/bootstrap.ini -e "variable_host=bootstrap"

# 4. Install Docker
ansible-playbook play--20-docker.yml -i /tmp/bootstrap.ini -e "variable_host=bootstrap"

# 5. Install and connect Tailscale
ansible-playbook play--21-tailscale-install.yml -i /tmp/bootstrap.ini -e "variable_host=bootstrap"
TAILSCALE_AUTH_KEY=tskey-auth-xxx ansible-playbook play--22-tailscale-up.yml -i /tmp/bootstrap.ini -e "variable_host=bootstrap"

# 6. Cleanup
rm /tmp/bootstrap.ini
```
