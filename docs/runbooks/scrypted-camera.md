# Scrypted Play-Area Camera

Operator runbook for the play-area camera: a spare **Nothing Phone 1** running the Android **IP Webcam** app emits RTSP on the LAN; **Scrypted** on host `home` bridges that RTSP feed into HomeKit; an **Apple TV** home hub performs HomeKit Secure Video (HSV) end-to-end encrypted recording to iCloud+.

## Privacy Invariants

These are non-negotiable. Every phase preserves them.

| ID  | Invariant                                                               |
| --- | ----------------------------------------------------------------------- |
| V1  | Camera phone (`192.168.1.201`) has **zero internet egress** — LAN only. |
| V2  | RTSP never leaves the LAN. **No port-forward**, no NAT exposure.        |
| V3  | Only HSV (E2E-encrypted on the Apple TV) leaves the house, to iCloud+.  |
| V4  | Tailscale is **admin-only**, never stream transport.                    |
| V5  | Scrypted is **never** fronted by cloudflared.                           |

## Topology

```
Nothing Phone 1 (192.168.1.201)        home (192.168.1.200)            Apple TV (home hub)
  Android IP Webcam app          --->   Scrypted v0.143.0        --->    HomeKit Secure Video
  RTSP H.264 + audio                    RTSP -> HomeKit bridge           E2E encrypt -> iCloud+
  LAN only, no egress (V1)              https://home:10443
```

______________________________________________________________________

## Phase 0 - Prereqs

1. **iCloud+ tier**: confirm at least **50 GB** (covers 1 HSV camera). On iPhone: Settings -> Apple ID -> iCloud -> Manage Account Storage. One camera needs the 50 GB tier; HSV recordings do **not** count against the storage quota, but the tier gate still applies.
1. **Apple TV home hub**: confirm an Apple TV (or HomePod) is present, signed into the same Apple ID, and set as a home hub. In the Home app: Home Settings -> Home Hubs & Bridges -> the Apple TV shows **Connected**. The hub must be on the same subnet as `home` (no VLAN split) — see V3.
1. **Static IP reservation**: on the router, create a **DHCP reservation** binding the Nothing Phone 1 MAC to `192.168.1.201`. Verify the lease is reserved (not just currently leased) so the address never drifts.

______________________________________________________________________

## Phase 1 - IP Webcam (camera phone)

1. Install **IP Webcam** (Android) on the Nothing Phone 1 — Play Store `https://play.google.com/store/apps/details?id=com.pas.webcam` (developer *Thyoni Tech*). Closed-source / freemium; not on F-Droid. Minimal Google footprint (P7): sign into Play only if the install requires it; grant **camera + microphone only**, deny location.

1. Open the app -> scroll to **Connection settings** / **Local broadcasting**:

   - Enable **RTSP** streaming.
   - Video codec: **H.264** (HomeKit requires H.264 — never H.265).
   - Audio: **enabled** (e.g. AAC/Opus as offered).

1. Set a **username and password** for the stream (keep it simple alphanumeric — no special characters, since Scrypted's RTSP plugin needs clean URL credentials).

1. **Disable battery optimization** for IP Webcam and keep the app in the **foreground** (start the server, leave the screen on or use the app's "keep awake" option). Android: Settings -> Apps -> IP Webcam -> Battery -> **Unrestricted**.

1. Keep the phone on **wall power** permanently (continuous streaming drains battery).

1. Note the **RTSP URL shape**:

   ```
   rtsp://<user>:<pass>@192.168.1.201:<port>/<path>
   ```

   The app displays the exact port and path on its running-server screen (commonly `:8080` HTTP with an RTSP port like `:5554`/`:8554`, path often `/h264_ulaw.sdp` or `/h264_pcm.sdp` — read it off the app, do not assume).

1. **Validate on-LAN** from another LAN host (a laptop on `192.168.1.0/24`, **not** over Tailscale — V4):

   ```bash
   ffprobe -rtsp_transport tcp "rtsp://<user>:<pass>@192.168.1.201:<port>/<path>"
   ```

   Or open the same URL in **VLC** (Media -> Open Network Stream). Confirm a video stream with codec `h264` and an audio track. If ffprobe reports the streams, the feed is good.

______________________________________________________________________

## Phase 2 - Isolation (invariant V1)

> **Trust model:** IP Webcam is closed-source, so trust is enforced at the network layer — not the app. This isolation plus the V1 check are the real privacy control: a fully WAN-blocked phone cannot exfiltrate regardless of app internals. A self-hosted open-source camera app may replace IP Webcam later; the isolation requirement is identical either way.

Block all WAN egress for the camera phone. Either approach is acceptable.

- **Option A — IoT VLAN**: move `192.168.1.201` onto the IoT VLAN with a firewall policy that permits `LAN -> home` (so Scrypted can pull RTSP) and **denies** the phone any route to WAN/internet.
- **Option B — Firewall rule**: on the gateway, add a rule blocking outbound WAN for source `192.168.1.201`, allowing only intra-LAN (`192.168.1.0/24`) traffic.

### Verify zero egress (V1)

On the gateway, run tcpdump filtered to the phone IP, excluding LAN destinations. Any captured packet is a violation.

```bash
tcpdump -ni any 'host 192.168.1.201 and not net 192.168.1.0/24'
```

Let it run for a few minutes while the camera streams and motion occurs. **Expect zero packets.** If anything appears, the egress block is leaking — fix the firewall/VLAN before proceeding. This check is **invariant V1**.

______________________________________________________________________

## Phase 3 - Deploy Scrypted

> **WARNING — use `-t scrypted` ONLY.** Host `home` is a member of both `homebridge_stack` and `scrypted_stack`. Running **bare** `apps.yml` (no tag) matches the homebridge role's `when` clause too, and would **recreate the running Homebridge container**, dropping its HomeKit pairings. Always scope the run with the `scrypted` tag.

1. From the `ansible/` directory, run **exactly**:

   ```bash
   ansible-playbook playbooks/apps.yml -t scrypted -i inventories/arpigesh/hosts.yml --ask-vault-pass
   ```

   This deploys the Scrypted role only: `ghcr.io/koush/scrypted:v0.143.0`, `network_mode: host` (required for HomeKit mDNS discovery), `restart: unless-stopped`, volume `./volume:/server/volume`.

1. Open the Scrypted web UI at **https://home:10443** (HTTPS only; accept the self-signed certificate warning on first access). Create the admin login on first run.

1. In **Plugins**, install:

   - `@scrypted/rtsp`
   - `@scrypted/rebroadcast`
   - `@scrypted/prebuffer-mixin`
   - `@scrypted/homekit`

1. **Add the RTSP camera**: use the RTSP plugin to add a camera with the URL and creds from Phase 1:

   ```
   rtsp://<user>:<pass>@192.168.1.201:<port>/<path>
   ```

   Add all available streams (Main + Substream if present). Verify the codec is **H.264** (not H.265). Prefer **Digest** authorization over Basic if the camera offers it.

1. **Enable prebuffer**: the rebroadcast + prebuffer-mixin plugins are automatic once installed — they hold ~10 s of recent video in memory so HSV notifications include pre-event footage. Confirm the rebroadcast mixin is enabled on the camera device.

1. Confirm the **HomeKit** plugin is enabled on the camera device (Accessory Mode by default — each camera pairs individually, not via the bridge meant for switches).

______________________________________________________________________

## Phase 4 - HomeKit + HSV

All of this happens in the **iOS Home app** (not the Scrypted web UI).

1. In the Scrypted web UI, open the camera device -> **HomeKit Settings** -> note the QR code and the 8-digit manual setup code (`XXX-XX-XXX`).
1. iOS Home app -> **+** -> Add Accessory -> **scan the QR code** (or enter the 8-digit code if the scan fails). Pair the camera.
1. **Assign the Apple TV as home hub** (Phase 0 already confirmed it — verify it shows **Connected** under Home Settings -> Home Hubs & Bridges).
1. **Enable HomeKit Secure Video**: tap the camera -> Settings -> **Stream & Recording** -> select **Record video when motion is detected**. Set retention to **10 days** (rolling).
1. **Activity zones**: Settings -> **Activity Zones** -> draw zones over the play area / walkway, exclude landscaping/vegetation to cut false triggers.
1. **Notifications**: enable **motion**, **person**, and **animal** notifications as desired (Settings -> Notifications).

> HSV recording requires the Apple TV home hub on the **same subnet** as `home` (V3). If the hub and Scrypted are split across VLANs, recording will not initiate.

______________________________________________________________________

## Phase 5 - Remote verify

Confirm the away-from-home path works **without any port-forward** (V2).

1. On an iPhone signed into the Home, turn **Wi-Fi off** (force cellular).
1. Open the Home app -> the camera -> confirm **live view** loads over cellular.
1. Trigger motion in front of the camera -> confirm a **motion/person notification** arrives on the phone, and the HSV clip is viewable.

This proves the remote path runs entirely through Apple's HomeKit relay + the Apple TV hub — no inbound NAT, no port-forward, no cloudflared (V2, V5).

______________________________________________________________________

## Phase 6 - Audio detection (optional)

If you want sound-based triggers in addition to motion:

1. In the Scrypted web UI, install an audio-detection / audio-volume mixin add-on.
1. Enable it on the camera device and tune the threshold.
1. The detection surfaces as a HomeKit sensor; configure its notifications in the iOS Home app like any other trigger.

______________________________________________________________________

## Credentials

The RTSP **username/password** live in two places only:

- The **IP Webcam** app on the Nothing Phone 1.
- The **Scrypted web UI** camera config (stored in Scrypted's persistent `volume/`).

Store them in your **password manager** or as an **ansible-vault** reference for recovery. **Never commit them** to the repo in plaintext. They are not stored in `docker-compose.yml` or any tracked file.
