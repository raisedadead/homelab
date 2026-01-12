# Secrets Management

This document describes how secrets are managed in the homelab Ansible configuration.

## Overview

Secrets are stored using **ansible-vault** encrypted files. Each site has its own vault file with site-specific secrets.

## Vault Files

| Site | File | Secrets |
|------|------|---------|
| Arpigesh | `inventories/arpigesh/group_vars/vault.yml` | Tailscale auth key |
| Malati | `inventories/malati/group_vars/vault.yml` | Tailscale auth key, Cloudflare tunnel token |

## Secrets Reference

### `vault_tailscale_auth_key`

- **Used by:** `roles/services/tailscale`
- **Purpose:** Authenticates new nodes to the Tailscale network
- **Where to get it:** [Tailscale Admin Console](https://login.tailscale.com/admin/settings/keys)
- **Key settings:**
  - Reusable: Yes (for multiple nodes)
  - Expiration: Set based on your preference
  - Tags: Match your ACL tags (e.g., `tag:services`)

### `vault_cloudflared_token`

- **Used by:** `roles/services/cloudflared`
- **Purpose:** Authenticates the Cloudflare Tunnel daemon
- **Where to get it:** [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/) > Access > Tunnels > Create/Configure tunnel
- **Note:** Each tunnel has its own token

## Workflow

### Initial Setup (one-time per machine)

```bash
cd ~/DEV/rd/homelab/ansible

# 1. Create vault password file
echo "your-secure-password" > .vault_pass
chmod 600 .vault_pass

# 2. Store this password in your password manager!
```

### Adding Real Secrets

```bash
# Edit vault file (opens in $EDITOR)
ansible-vault edit inventories/arpigesh/group_vars/vault.yml

# Replace placeholder values with actual secrets
# Save and exit - file is automatically re-encrypted
```

### Encrypting Vault Files (first time)

```bash
# After adding real values, encrypt the files
ansible-vault encrypt inventories/arpigesh/group_vars/vault.yml
ansible-vault encrypt inventories/malati/group_vars/vault.yml
```

### Common Commands

```bash
# View encrypted file contents
ansible-vault view inventories/arpigesh/group_vars/vault.yml

# Edit encrypted file
ansible-vault edit inventories/arpigesh/group_vars/vault.yml

# Re-key (change vault password)
ansible-vault rekey inventories/*/group_vars/vault.yml

# Decrypt in place (use with caution!)
ansible-vault decrypt inventories/arpigesh/group_vars/vault.yml
```

### Running Playbooks

With `.vault_pass` file in place (configured in `ansible.cfg`):
```bash
# Vault is automatically decrypted
ansible-playbook playbooks/site.yml -i inventories/arpigesh/hosts.yml
```

Without `.vault_pass` file:
```bash
# Prompt for password
ansible-playbook playbooks/site.yml -i inventories/arpigesh/hosts.yml --ask-vault-pass
```

## Security Notes

- `.vault_pass` is gitignored and must never be committed
- `vault.yml` files are safe to commit when encrypted (they start with `$ANSIBLE_VAULT;1.1;AES256`)
- Store vault password in a password manager for recovery
- Use separate Tailscale auth keys per site for easier revocation
- Rotate secrets periodically (Tailscale keys expire based on your settings)

## File Locations

```
ansible/
  .vault_pass                    # Vault password (gitignored, local only)
  ansible.cfg                    # Points to .vault_pass
  inventories/
    arpigesh/
      group_vars/
        vault.yml                # Encrypted secrets for Arpigesh
    malati/
      group_vars/
        vault.yml                # Encrypted secrets for Malati
```
