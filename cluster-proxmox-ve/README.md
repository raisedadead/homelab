# Instructions & Notes

Pre-requisites:

- The remote host (PVE installation) should be accessible via SSH. Check LAN and
  Network interfaces. If using a FQDN, make sure it is resolvable.
- The SSH public key of the local user should be added to the remote host's
  `~/.ssh/authorized_keys` file.

  ```shell
  apt install ssh-import-id
  ssh-import-id gh:username
  ```
