# IDS/IPS Suricata

> Ask yourself which system (or systems) in the network layout of the company would be best suited to install IDS/IPS software on. Revert back to the original network diagram of the initial setup and answer the same questions as well.
>     What traffic can be seen?
>     What traffic (if any) will be missed and when?
> 
> For this exercise, disable the firewall so that you can reach the database. Install tcpdump on the machine where you will install Suricata on and increase the memory (temporary if needed) to at least 4GB. Reboot if necessary.
> 
> Verify that you see packets (in tcpdump) from red to the database. Try this by issuing a ping and by using the hydra mysql attack as seen previously. Are you able to see this traffic in tcpdump? What about a ping between the webserver and the database?
> 
> Install and configure the Suricata software. Keep it simple and stick to the default configuration file(s) as much as possible. Change the interface to the one you want to sniff on in the correct Suricata configuration file. Focus on 1 interface when starting out!
> 
> Create your own alert rules.
> - What is the difference between the fast.log and the eve.json files?
> - Create a rule that alerts as soon as a ping is performed between two machines (for example red and database)
> - Test your out-of-the-box configuration and browse on your red machine to www.insecure.cyb/cmd and enter "id" as an evil command. Does it trigger an alert? If not are you able to make it trigger an alert?
> - Create an alert that checks the mysql tcp port and rerun a hydra attack to check this rule. Can you visually see this bruteforce attack in the fast.log file? Tip: monitor the file live with an option of tail.
> - Go have a look at the Suricata documentation. What is the default configuration of Suricata, is it an IPS or IDS?
> - What do you have to change to the setup to switch to the other (IPS or IDS)? You are free to experiment more and go all out with variables (for the networks) and rules. Make sure you can conceptually explain why certain rules would be useful and where (= from which subnet to which subnet) they should be applied?
> 
> To illustrate the difference between an IPS and firewall, enable the firewall and redo the hydra attack through an SSH tunnel. Can you make sure that Suricata detects this attack as an IPS? Do you understand why Suricata can offer this protection whilst a firewall cannot? What is the difference between an IPS and firewall? On which layers of the OSI-model do they work?

## Preperation

The `companyrouter` will be my vm of choice for the ids system because it's the entrypoint to the company network.

- What traffic can be seen?
  - If monitoring the interface facing outwards, all outgoing traffic from the internal hosts and all incoming traffic to the internal network can be monitored
- What traffic (if any) will be missed and when?
  - Traffic that does not pass one of the `companyrouter`'s interfaces cannot be monitored, e.g. when two machines communicate directly in their subnet.
  - In the original network layout, there was more direct traffic that could not be monitored by the router.
  - The new subnetted layout makes more traffic pass through the router to route between the 3 subnets.

### Monitoring traffic

```sh
# traffic to and from database passing through eth0 (internet facing)
sudo tcpdump -i eth0 host 172.30.0.15

# traffic from and to db coming from/going to servers subnet
sudo tcpdump -i eth1 host 172.30.0.15
```

## Installation

> https://docs.suricata.io/en/latest/install.html#binary-packages

```sh
sudo dnf install epel-release dnf-plugins-core
sudo dnf copr enable @oisf/suricata-7.0
sudo dnf install suricata
```

> 3.2.3.2. Additional Notes for RPM Installations
> 
> - Suricata is pre-configured to run as the suricata user.
> 
> - Command line parameters such as providing the interface names can be configured in `/etc/sysconfig/suricata`.
> 
> - Users can run `suricata-update` without being root provided they are added to the suricata group.
> 
> - Directories:
> 
>         /etc/suricata: Configuration directory
> 
>         /var/log/suricata: Log directory
> 
>         /var/lib/suricata: State directory rules, datasets.

```sh
# Manage from systemd
sudo systemctl start/stop suricata

# reload rules with
sudo systemctl reload suricata

# installation version info
sudo suricata --build-info
```

## Configuration

- change `/etc/suricata/suricata.yaml`
```yaml

HOME_NET: "[172.30.0.0/24,172.30.20.0/24,172.30.100.0/24,172.123.0.0/24]"

[...]

rule-files:
  - suricata.rules
  - custom.rules # <-- Add this

af-packet:
    - interface: enp1s0
      cluster-id: 99
      cluster-type: cluster_flow
      defrag: yes
      use-mmap: yes
      tpacket-v3: yes
```

- update signature/rules with `sudo suricata-update`
- rules are installed to `/var/lib/suricata/rules`

## Creating Alert Rules

- create `/var/lib/suricata/rules/custom.rules` and add the custom rules there.

> https://www.digitalocean.com/community/tutorials/understanding-suricata-signatures

example:
```
ACTION HEADER OPTIONS
alert icmp any any -> 76.76.21.21 any (msg: "Pinged technikum-wien.at"; content:"technikum-wien.at"; classtype:ping; sid:69;)
```

- ACTION: alert, reject (ips), drop (ips), pass
- HEADER:  network protocol, source and destination IP addresses, ports, and direction of traffic
- OPTIONS: specific parameter for the rule

### Options

Some important suricata options:

- `content`, e.g. `content:"uid=0|28|root|29|";`: look for a specific string in a request
- `msg`: provide information for logs what the rule detects
- `sid`: unique id of a rule `1000000-1999999` is reserved for custom rules

## Questions

### What is the difference between the fast.log and the eve.json files?

- `fast.log` contains all alerts generated, in a easily readable formal
- `eve.json` outputs alerts, anomalies, metadata, file info and protocol specific records through JSON.

**Example:**
DNS request to twitter.com

Rule:
```
alert dns any any -> any 53 (msg:"Twitter - DNS request for twitter.com"; dns_query; content:"twitter.com"; nocase; classtype:social-media; sid:13;)
```

`sudo tail -f /var/log/suricata/fast.log` output:
```
1/09/2024-22:37:23.566146  [**] [1:13:0] Twitter - DNS request for twitter.com [**] [Classification: (null)] [Priority: 3] {UDP} 192.168.100.253:46893 -> 10.0.2.3:53
```

EVE output: `sudo tail -f /var/log/suricata/eve.json | jq 'select(.event_type=="alert")'`
```json
{
  "timestamp": "2024-01-09T22:37:23.566146+0000",
  "flow_id": 1024206284956262,
  "in_iface": "eth0",
  "event_type": "alert",
  "src_ip": "192.168.100.253",
  "src_port": 46893,
  "dest_ip": "10.0.2.3",
  "dest_port": 53,
  "proto": "UDP",
  "pkt_src": "wire/pcap",
  "tx_id": 0,
  "alert": {
    "action": "allowed",
    "gid": 1,
    "signature_id": 13,
    "rev": 0,
    "signature": "Twitter - DNS request for twitter.com",
    "category": "",
    "severity": 3
  },
  "dns": {
    "query": [
      {
        "type": "query",
        "id": 49738,
        "rrname": "twitter.com",
        "rrtype": "A",
        "tx_id": 0,
        "opcode": 0
      }
    ]
  },
  "app_proto": "dns",
  "direction": "to_server",
  "flow": {
    "pkts_toserver": 1,
    "pkts_toclient": 0,
    "bytes_toserver": 94,
    "bytes_toclient": 0,
    "start": "2024-01-09T22:37:23.566146+0000",
    "src_ip": "192.168.100.253",
    "dest_ip": "10.0.2.3",
    "src_port": 46893,
    "dest_port": 53
  }
}
```

### Create a rule that alerts as soon as a ping is performed between two machines (for example red and database)

Rule:
```
alert icmp 192.168.100.99 any -> 172.30.0.15 any (msg: "UNWATED PING DETECTED"; classtype:ping; sid:69;)
```

Alert:
```
1/09/2024-22:47:33.124924  [**] [1:69:0] UNWATED PING DETECTED [**] [Classification: (null)] [Priority: 3] {ICMP} 192.168.100.99:8 -> 172.30.0.15:0
01/09/2024-22:47:33.124924  [**] [1:2100366:8] GPL ICMP_INFO PING *NIX [**] [Classification: Misc activity] [Priority: 3] {ICMP} 192.168.100.99:8 -> 172.30.0.15:0
```

### Others

> - Test your out-of-the-box configuration and browse on your red machine to www.insecure.cyb/cmd and enter "id" as an evil command. Does it trigger an alert? If not are you able to make it trigger an alert?

```
01/09/2024-22:50:15.037334  [**] [1:2019284:3] ET ATTACK_RESPONSE Output of id command from HTTP server [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 172.30.20.10:80 -> 192.168.100.99:55386
01/09/2024-22:50:15.037334  [**] [1:2100498:7] GPL ATTACK_RESPONSE id check returned root [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 172.30.20.10:80 -> 192.168.100.99:55386
01/09/2024-22:50:20.038827  [**] [1:2019284:3] ET ATTACK_RESPONSE Output of id command from HTTP server [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 172.30.20.10:80 -> 192.168.100.99:55386
01/09/2024-22:50:20.038827  [**] [1:2100498:7] GPL ATTACK_RESPONSE id check returned root [**] [Classification: Potentially Bad Traffic] [Priority: 2] {TCP} 172.30.20.10:80 -> 192.168.100.99:55386
```

> - Create an alert that checks the mysql tcp port and rerun a hydra attack to check this rule. Can you visually see this bruteforce attack in the fast.log file? Tip: monitor the file live with an option of tail.

> - Go have a look at the Suricata documentation. What is the default configuration of Suricata, is it an IPS or IDS?

IDS is the default configuration.

> - What do you have to change to the setup to switch to the other (IPS or IDS)? You are free to experiment more and go all out with variables (for the networks) and rules. Make sure you can conceptually explain why certain rules would be useful and where (= from which subnet to which subnet) they should be applied?