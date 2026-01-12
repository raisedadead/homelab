# Ansible Playbooks

Role-based configuration management for multi-site homelab infrastructure.

## Setup

```bash
cd ansible
make install
source .venv/bin/activate
```

## Directory Structure

```
ansible/
├── inventories/
│   ├── arpigesh/           # Primary site
│   │   ├── hosts.yml
│   │   ├── group_vars/
│   │   │   ├── all.yml
│   │   │   └── vault.yml   # Encrypted secrets
│   │   └── host_vars/
│   └── malati/             # Remote site
│       ├── hosts.yml
│       ├── group_vars/
│       └── host_vars/
├── roles/
│   ├── base/               # System setup
│   │   ├── user/
│   │   ├── ssh/
│   │   ├── locale/
│   │   └── hostname/
│   ├── services/           # Infrastructure
│   │   ├── docker/
│   │   ├── tailscale/
│   │   └── cloudflared/
│   └── apps/               # Applications
│       ├── portainer/
│       └── homeassistant/
├── playbooks/
│   ├── bootstrap.yml       # Initial host setup
│   ├── services.yml        # Infrastructure services
│   ├── apps.yml            # Container apps
│   ├── site.yml            # Full deployment
│   └── maintenance/
│       ├── update.yml
│       ├── reboot.yml
│       └── check.yml
└── group_vars/
    └── all.yml             # Global defaults
```

## Playbooks

| Playbook | Purpose | Tags |
|----------|---------|------|
| `bootstrap.yml` | Initial host setup | user, ssh, locale, hostname |
| `services.yml` | Infrastructure services | docker, tailscale, cloudflared |
| `apps.yml` | Container applications | portainer, homeassistant |
| `site.yml` | Full deployment | all above |
| `maintenance/update.yml` | System updates | - |
| `maintenance/reboot.yml` | Reboot/shutdown | - |
| `maintenance/check.yml` | System status | - |

## Usage

### Using Make (Recommended)

```bash
# Test connection
make ping SITE=malati

# Check system status
make check SITE=malati

# Bootstrap new host
make bootstrap SITE=malati HOST=malati-pi

# Deploy services (requires vault password)
make services SITE=malati

# Deploy applications
make apps SITE=malati

# Full site deployment
make site SITE=malati

# System maintenance
make update SITE=malati
make reboot SITE=malati
```

### Using ansible-playbook Directly

```bash
# Bootstrap
ansible-playbook playbooks/bootstrap.yml -i inventories/malati/hosts.yml -l malati-pi

# With tags
ansible-playbook playbooks/bootstrap.yml -i inventories/malati/hosts.yml --tags user,ssh

# With vault
ansible-playbook playbooks/services.yml -i inventories/malati/hosts.yml --ask-vault-pass

# Limit to specific host
ansible-playbook playbooks/site.yml -i inventories/malati/hosts.yml -l malati-pi --ask-vault-pass
```

## Vault Management

Secrets are stored in `inventories/<site>/group_vars/vault.yml` and encrypted with ansible-vault.

```bash
# Create vault password file (one-time, gitignored)
echo "your-vault-password" > .vault_pass
chmod 600 .vault_pass

# Encrypt vault file
make vault-encrypt SITE=malati

# Edit vault secrets
make vault-edit SITE=malati
```

### Vault Variables

| Variable | Description |
|----------|-------------|
| `vault_tailscale_auth_key` | Tailscale auth key |
| `vault_cloudflared_token` | Cloudflare tunnel token |

## Variables

### Global Defaults (`group_vars/all.yml`)

| Variable | Default | Description |
|----------|---------|-------------|
| `default_user` | `malati` | Primary user |
| `default_github_users` | `[raisedadead, prayashm]` | SSH key sources |
| `default_locale_lang` | `en_US.UTF-8` | System locale |
| `default_timezone` | `Asia/Kolkata` | Timezone |
| `default_domain` | `lan.mrugesh.net` | FQDN domain |
| `default_tailscale_tags` | `tag:services` | Tailscale ACL tags |

### Site Overrides

Override in `inventories/<site>/group_vars/all.yml` or `host_vars/<host>.yml`.

## New Host Bootstrap

See [Bootstrap Runbook](bootstrap.md) for detailed new host onboarding.
