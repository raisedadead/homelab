# Bootstrap New Host

Onboarding a new Raspberry Pi into the homelab.

## Prerequisites

- Raspberry Pi with Raspberry Pi OS flashed
- SSH enabled (add empty `ssh` file to boot partition)
- Network connectivity (Ethernet or WiFi)
- Default credentials: `pi` / `raspberry`

## Quick Start

### 1. Add to Inventory

Edit `ansible/inventories/<site>/hosts.yml`:

```yaml
all:
  children:
    <stack_name>:
      hosts:
        <hostname>:
          ansible_host: <ip_or_hostname>
          ansible_user: pi  # Initial user, will be changed
```

### 2. Create Host Variables (Optional)

Create `ansible/inventories/<site>/host_vars/<hostname>.yml`:

```yaml
tailscale_hostname: <hostname>
tailscale_tags: "tag:services"
```

### 3. Run Bootstrap

```bash
cd ansible
source .venv/bin/activate

# Bootstrap with default pi user
ansible-playbook playbooks/bootstrap.yml \
  -i inventories/<site>/hosts.yml \
  -l <hostname> \
  -e "ansible_user=pi ansible_password=raspberry"
```

### 4. Update Inventory

After bootstrap, update inventory to use new user:

```yaml
<hostname>:
  ansible_host: <hostname>  # Can use Tailscale MagicDNS after services
  ansible_user: malati      # New user from bootstrap
```

### 5. Deploy Services

```bash
# Set up vault with Tailscale auth key first
make vault-edit SITE=<site>

# Deploy services
make services SITE=<site>
```

### 6. Deploy Applications

```bash
make apps SITE=<site>
```

## Site-Specific Procedures

### Malati (Home Assistant)

Full stack deployment:

```bash
# 1. Bootstrap
make bootstrap SITE=malati HOST=malati-pi

# 2. Services (Docker, Tailscale, Cloudflared)
make services SITE=malati

# 3. Apps (Portainer, Home Assistant)
make apps SITE=malati
```

Or all-in-one:

```bash
make site SITE=malati
```

### Arpigesh (Homebridge)

```bash
# 1. Bootstrap
make bootstrap SITE=arpigesh HOST=home

# 2. Services (Docker, Tailscale only)
make services SITE=arpigesh
```

## Troubleshooting

### SSH Connection Refused

```bash
# Check if SSH is enabled
ping <hostname>.local

# Force password auth for initial connection
ansible-playbook playbooks/bootstrap.yml \
  -i inventories/<site>/hosts.yml \
  -l <hostname> \
  -e "ansible_user=pi" \
  --ask-pass
```

### Locale Warnings

These are expected on fresh Raspberry Pi OS. The locale role fixes them.

### Tailscale Auth Failed

1. Generate new auth key at https://login.tailscale.com/admin/settings/keys
2. Update vault: `make vault-edit SITE=<site>`
3. Re-run: `make services SITE=<site>`
