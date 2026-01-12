# Arpigesh

Primary site (home).

## Hardware

### DeskPi Super6C Cluster

| Slot | Module | Hostname | Services |
|------|--------|----------|----------|
| 1 | CM4 | TBD | TBD |
| 2 | CM4 | TBD | TBD |
| 3 | CM4 | TBD | TBD |
| 4 | CM4 | TBD | TBD |
| 5 | CM4 | TBD | TBD |
| 6 | CM4 | TBD | TBD |

### Standalone Devices

| Device | Board | Hostname | OS | Services |
|--------|-------|----------|-----|----------|
| Raspberry Pi CM4 | Waveshare CM4-DUAL-ETH-MINI | `home` | Debian Bookworm (aarch64) | Homebridge |

#### CM4-DUAL-ETH-MINI Specs
- Dual Gigabit Ethernet ports
- Compact form factor with case
- Kernel: 6.12.x (rpi-v8)

## Services

### Homebridge

- **Host**: `home`
- **Container**: `homebridge/homebridge:latest`
- **Access**: Tailscale MagicDNS
- **Purpose**: HomeKit bridge for non-HomeKit smart devices
- **Web UI**: `http://home:8581`

## Network

- LAN: DHCP
- Tailscale: Connected (`home`)

## Ansible Inventory

```yaml
# inventories/arpigesh/hosts.yml
all:
  children:
    standalone:
      hosts:
        home:
          ansible_host: home
    homebridge_stack:
      hosts:
        home:
```

## Rebuild

1. Flash Raspberry Pi OS (64-bit, Lite) to SD/eMMC
2. Enable SSH, configure WiFi if needed
3. Bootstrap: `make bootstrap SITE=arpigesh HOST=home`
4. Services: `make services SITE=arpigesh`
5. Deploy Homebridge manually or add role
