# Honeypots - Cowrie

## Setup
- install docker (podman) on `companyrouter`
  - `sudo dnf install docker`
- run cowrie container `docker run -d -p 2222:2222 --name cowrie cowrie/cowrie:latest`
- inspect logs with `docker logs cowrie`

## Questions

1. Why is companyrouter, in this environment, an interesting device to configure with a SSH honeypot? What could be a good argument to NOT configure the router with a honeypot service?
   - the companyrouter is the only machine in the internal network exposed to the fake internet and is the obvious entrypoint

2. Change your current SSH configuration in such a way that the SSH server (daemon) is not listening on port 22 anymore but on port 2222.
   - skipped, just runs on 2222

3. Install and run the cowrie software on the router and listen on port 22 - the default SSH server port.
   - skipped

4. Once configured and up and running, verify that you can still SSH to the router normally, using port 2222.
    - skipped

5. Attack your router and try to SSH normally. What do you notice?
- What credentials work? Do you find credentials that don't work?
  - root:password
  - root:somepassword
- Do you get a shell?
  - yes, a bash
- Are your commands logged? Is the IP address of the SSH client logged? If this is the case, where?
  ```sh
    2024-01-04T00:35:29+0000 [HoneyPotSSHTransport,5,10.0.2.100] login attempt [b'root'/b'password'] succeeded
    2024-01-04T00:32:20+0000 [twisted.conch.ssh.session#info] Getting shell
    2024-01-04T00:32:21+0000 [HoneyPotSSHTransport,4,10.0.2.100] CMD: apt
    2024-01-04T00:32:21+0000 [HoneyPotSSHTransport,4,10.0.2.100] Can't find command apt
    2024-01-04T00:32:21+0000 [HoneyPotSSHTransport,4,10.0.2.100] Command not found: apt
  ```
- Can an attacker perform malicious things?
  - not really
- Are the actions, in other words the commands, logged to a file? Which file?
  ```sh
  2024-01-04T00:38:29+0000 [HoneyPotSSHTransport,5,10.0.2.100] Closing TTY Log: var/lib/cowrie/tty/5076bd8cae34c22279c9d452fc84c4ad8d692153dea3e1f6fe01d2813c8903f3 after 179 seconds
  ```
- If you are an experienced hacker, how would/can you realize this is not a normal environment?
  - no package manager
  - very few env variables
  - bash history removed after relogin
  - no networking configuration to be found (no ip cmd, no `/etc/network/interfaces`)


## Critical thinking when using "Docker as a service"

- What are some (at least 2) advantages of running services (for example cowrie but it could be sql server as well) using docker?
  - Compatibility
  - Isolation
- What could be a disadvantage? Give at least 1.
  - resource limitations?
- Explain what is meant with "Docker uses a client-server architecture."
- As which user is the docker daemon running by default? Tip: https://docs.docker.com/engine/install/linux-postinstall/ .
  - runs as root normally, but `podman`, the docker replacement shipped with RedHat based systems does not
- What could be an advantage of running a honeypot inside a virtual machine compared to running it inside a container?
  - realistic system properties (memory, cpu, disks, etc.)
