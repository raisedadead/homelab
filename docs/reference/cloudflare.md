# Cloudflare

DNS management via Terraform.

## Zone

- **Domain**: `mrugesh.net`
- **Plan**: Free
- **Terraform Workspace**: `tfws-ops-cloudflare`

## DNS Records

| Record | Type | Content | Proxied |
|--------|------|---------|---------|
| `mrugesh.net` | A | `192.0.2.1` | Yes |
| `www` | CNAME | `mrugesh.net` | Yes |
| `home` | A | `192.168.1.200` | No |
| `_dmarc` | TXT | DMARC policy | No |
| `mrugesh.net` | TXT | SPF policy | No |

## Terraform

### Setup

```bash
cd terraform/cloudflare
cp terraform.tfvars.sample terraform.tfvars
# Edit terraform.tfvars with API token and zone ID
terraform init
```

### Apply Changes

```bash
terraform plan
terraform apply
```

### Required Variables

| Variable | Description |
|----------|-------------|
| `cloudflare_api_token` | API token with Zone:DNS:Edit |
| `cloudflare_account_id` | Cloudflare account ID |
| `cloudflare_zone_id_mrugesh_net` | Zone ID for mrugesh.net |

## Files

```
terraform/cloudflare/
├── main.tf                 # Provider, workspace, zone resource
├── variables.tf            # Variable definitions
├── terraform.tfvars        # Variable values (gitignored)
├── zone-mrugesh-net.tf     # DNS records
└── outputs.tf              # (empty)
```
