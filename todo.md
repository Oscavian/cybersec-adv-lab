- [x] A working environment, virtual machines are up and running and you have created your own network diagram documentation.
- [x] All machines can contact each other over the network when in an "unsafe state".
- [x] All machines have internet access thanks to the isp- and companyrouters.
- [x] You have set up a red machine in the hostonly network and configured it in such a way that it is able to reach out all other machines in the network and has internet access.
- [x] You have performed some attacks (DNS zone transfer, database bruteforce, etc) that are successful from the red machine to other machines on the network if your firewall is not blocking it.
- [ ] You have a configuration of a firewall on the companyrouter that can block traffic from the yellow network to the companynetwork while still allowing machines to access the webserver (tip: use nftables). You have verified this with the red machine and can easily revert back to the unsafe state.
- [ ] You have a working ssh honeypot and are able to view logs.
- [ ] You have installed and configured a proof-of-concept with suricata to function as an IDS using a self-written rule.
- [x] You have created your own notes and documentation


- OpenVPN & IPSec prioritise! More complicated than other chapters

- [ ] Honeypot Cowrie
- [ ] Wazuh
- [ ] Backups



- Wazuh - collect a lot of logs
  - show logs from windows client to siem
  - logs from event viewer are shipped to wazuh
  - proc create shown in wazuh log
  - focus on powershell cmdlets
- IPSec: Just demonstrating an encrypted tunnel is enough (almost all points)   
  - show encrypted network traffic

Theory question:
- Difference IPSec OPenVPN
- Honeypot
- Wazuh
- incremental vs. full backup

Ansible:
- ad hoc command
- `ansible <machine> -m <module> "src=/tmp dest=/tmp"`
- question 2 