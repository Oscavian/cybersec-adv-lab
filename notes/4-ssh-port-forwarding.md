# Class Notes

https://overthewire.org/wargames/

https://cfgmgmtcamp.eu/ghent2023/

https://cybersecuritychallenge.be/

https://snyk.io/events/ctf/

## SSH Options

`-L` - local port forwarding

- “poor man’s vpn”
- e.g. `ssh -L 8000:facebook.com:443 user@ip`

`-R` - reverse port forwarding, open a remote port (e.g. tunnel from private vm to public vps)

- `ssh -R 80:localhost user@ip`
- needs GatewayPorts option enabled
- no NATting necessary on the companyrouter, not a security practice

# Security Onion

Abbreviation: so

# Honeypots