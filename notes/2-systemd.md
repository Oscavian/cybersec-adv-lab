# Systemd,  unit files

- `init` process, mommy of all processes, also zombies
- used to be `/etc/init.d` , plaintext scripts → OLD
- systemd is purely a Linux thing
- collection of programs and libraries
    - systemctl
    - journalctl
    - process mngmt
    - login mgmnt
    - logs

### Systemd unit

- “service”
- entity managed by systemd
- Examples:
    - services
    - socket files
    - devices
    - partition
- Locations:
    - `/lib/systemd/system` - standard systemd unit files (distro maintainers)
    - `/usr/lib/systemd/system` - from locally installed packages
    - `/run/systemd/system` - transient unit files
    - `/etc/systemd/system` - place for custom unit files, locally configured

### Systemd unit files

**Basic unit file**:

```bash
# /etc/systemd/service/sample.service

[Unit]
Description=Example
After=network-up.target

[Service]
ExecStart=/usr/local/bin/sampleprogram

[Install]
WantedBy=multi-user.target # unit is started during boot process
:wq

$ systemctl daemon-reload # reload available unit files, does not restart services
```

- Example more complex unit file: nginx

# Reverse proxy

## Forward Proxy

- *forwards* traffic from an internal network into the internet
- acts as a “firewall”, can filter traffic
- hides internal network
- can log user activity

## Reverse proxy

- regulates traffic coming into a network
- single point of entry
- increases security, hides internal ip addresses of servers
- block malicious traffic, ddos
- Load balancing