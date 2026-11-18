# Mac Personal Tailnet

This runbook tells how to use the personal tailnet from a Mac whose native Tailscale client stays on a different tailnet.

## Parts

- `home-net`: an isolated Alpine machine in OrbStack. It runs Tailscale on the personal tailnet as `mac-home-net`.
- `ssh home`: an SSH alias in `~/.ssh/config_home`. It connects through `home-net`.
- A SOCKS proxy on `127.0.0.1:1080`: an `ssh -D` tunnel into `home-net`.
- The Firefox profile `HomeTailnet`: it sends all traffic and DNS through the proxy.

The setup does not change the native Tailscale client, the macOS DNS settings or the macOS proxy settings.

## Start

1. Run `orb start home-net`.
1. Run `orb -m home-net -u root rc-service networking start`.
1. Run `orb -m home-net -u root rc-service tailscale start`.
1. Start the proxy:

   ```
   ssh -fNT -M -S ~/.ssh/home-net.control -o ExitOnForwardFailure=yes \
     -D 127.0.0.1:1080 home-net@orb
   ```

If step 4 shows that the control socket already exists, run `ssh -S ~/.ssh/home-net.control -O check home-net@orb`. If that check fails, remove `~/.ssh/home-net.control` and do step 4 again.

## Use

- SSH: run `ssh home`.
- Browser: run `/Applications/Firefox.app/Contents/MacOS/firefox -P HomeTailnet`.
- Homebridge: open `https://home.<tailnet>.ts.net:8581` in the `HomeTailnet` profile. Homebridge uses a self-signed certificate. Accept it once.
- DNS check: open `https://test.nextdns.io` in the `HomeTailnet` profile. `deviceName` shows `mac-home-net`.

Other Firefox profiles and other browsers do not use the proxy.

## Exit Node

The exit node sends the `HomeTailnet` traffic out through `home`. The rest of the Mac does not use it.

- Turn on: `orb -m home-net -u root tailscale set --exit-node=home`
- Turn off: `orb -m home-net -u root tailscale set --exit-node=`

To check, open `https://test.nextdns.io` in the `HomeTailnet` profile. `deviceName` shows `home` when the exit node is on.

## Stop

1. Run `ssh -S ~/.ssh/home-net.control -O exit home-net@orb`.
1. Run `orb stop home-net`.

OrbStack can start `home-net` at login. Tailscale and the proxy stay off until you do the steps in [Start](#start).

## Rebuild

Do these steps once, on a new Mac or after you delete `home-net`.

1. Run `orb create --isolated alpine:3.23 home-net`.
1. Install Tailscale from the Alpine edge repository:

   ```
   orb -m home-net -u root apk add \
     --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
     tailscale tailscale-openrc
   ```

1. Run `orb -m home-net -u root rc-service networking start`.
1. Run `orb -m home-net -u root rc-service tailscale start`.
1. Run `orb -m home-net -u root tailscale up --hostname=mac-home-net --accept-dns=true`.
1. Open the URL that the command shows. Sign in with the personal account.
1. Make sure that `~/.ssh/config` has the line `Include config_*`. If it does not, add the line at the end of the file.
1. Write `~/.ssh/config_home`:

   ```
   Host home
     HostName home.<tailnet>.ts.net
     User <user>
     ProxyJump home-net@orb
     StrictHostKeyChecking accept-new
   ```

1. Run `brew install --cask firefox`.
1. Create the profile:

   ```
   /Applications/Firefox.app/Contents/MacOS/firefox -CreateProfile \
     "HomeTailnet $HOME/Library/Application Support/Firefox/Profiles/home-tailnet"
   ```

1. Write `user.js` in that profile folder:

   ```
   user_pref("network.proxy.type", 1);
   user_pref("network.proxy.socks", "127.0.0.1");
   user_pref("network.proxy.socks_port", 1080);
   user_pref("network.proxy.socks_version", 5);
   user_pref("network.proxy.socks5_remote_dns", true);
   user_pref("network.proxy.no_proxies_on", "");
   user_pref("network.trr.mode", 5);
   user_pref("network.http.http3.enable", false);
   user_pref("media.peerconnection.ice.proxy_only", true);
   user_pref("browser.startup.homepage", "https://home.<tailnet>.ts.net:8581");
   ```

Do not run `rc-update add tailscale`. Tailscale in `home-net` must not start at boot.

The personal tailnet policy must let `autogroup:member` connect to `tag:services` as `<user>` in its `ssh` section. Without this rule, `ssh home` fails with `tailnet policy does not permit you to SSH to this node`.
