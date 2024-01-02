# SSH Bastion Server

- reduce attack service
- protect an internal network
- all connections from the outside go through the bastion host

## Config

### Basic Bastion

- Disable root user on internal server, create unpriviledged user instead
- generate ssh key for unpr. user and copy to internal servers
`ssh-copy-id root@172.16.0.2`

```
# /etc/ssh/sshd_config
# jump user will instantly forward the connection to the internal host 

PermitRootLogin no

Match User jump
		ForceCommand ssh root@172.16.0.1
```

### Client initiated jump

```
# /etc/ssh/sshd_config
# harden the jump user
# e.g. create a jump user for every internal service

Match User jump
		PermitTTY no
		X11Forwarding no
		PermitTunnel no
		GatewayPorts no
		ForceCommand /usr/sbin/nologin
```

- specify ssh jump host: `ssh -J jump@demo root@internal`
- To use Public Key auth, the internal server has to have the Clients publickey
- Only having pka between jump and internal wont work!! → whole connection is forwarded

### Interactive bastion

```
# /etc/ssh/sshd_config
# run a script when logging into the jump user
# requires TTY access because of interactiveness

Match User jump
		PermitTTY yes
		X11Forwarding no
		PermitTunnel no
		GatewayPorts no
		ForceCommand /home/jump/scripts/jump.sh
```

[Linux | How to create Terminal User Interfaces (TUI)](https://www.youtube.com/watch?v=FJ7KJXmZRXA)