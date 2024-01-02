# Class Notes

add static route persistently from isprouter to  companyrouter

# Course material

## DNS Attacks

### Cache Poisoning

- Corrupting cache info
- Version 1:
    - malicious host requests malicious auth. name server for a domain, the answer contains not only the requestes record, but an additional (malicious) record. The local resolver then caches BOTH of them.
    - Prevention: Bailiwick Check - ensure that the additional information in a response only contains information from the same domain
- Version 2:
    - attacker forges a malicious DNS answer
    - timing attack, attacker needs to be faster than the legit name server
    - needs to be well formed
        - udp port needs to match the request
        - question sections match ??
        - query ID match
        - Bailiwick check - additional data must be related to the domain
- Kaminsky attack
    - malicious auth name server in place
    - Query a random subdomain → not in cache
    - attacker brute forces answer, if accepted → attacker captured whole domain
- Mitigation:
    - Blocking spoofing
    - Move to DNSSEC → authenticate answers

### DDoS DNS

- Root servers use Anycast → more replicas per one IP Address
- Mitigation:
    - Response rate limiting
    - Filtering

### DNSSEC

`$ dig +dnssec cpsc.gov @auth.server.net` 

- Advantage: authenticated DNS queries
- Disadvantage: Signature takes up more space - RSA2048 signature
    - → makes DDoS Attacks easier because higher attack volume with lesser traffic possible → DNSSEC amplification
- Mitigation of DNSSEC amp.: block ANY request:
    - ANY queries blocking
- Mitigation by ECC:
    - Use Elyptic curve cryptography instead of RSA → more security with smaller keys

## DNS commands

### dig

Forward lookup:

`dig example.com ANY @8.8.8.8`

`dig example.com AAAA`

Reverse lookup:

`dig -x 8.8.8.8` 

Display trace:

`dig example.com +trace`

### nslookup

non-/ interactive

- non-auth. answer: response came from cache

`nslookup -type=AAAA google.com`

`nslookup -type=NS example.com`

## DNS zone transfers

[DNS Zone Transfer Vulnerability](https://beaglesecurity.com/blog/vulnerability/dns-zone-transfer.html)

- DNS query type axfr
- primary use case: replicating a zonefile from a primary to a secondary dns server
- Full transfer → repilicate everything → time-consuming
- Incremental transfer → only changes transferred
    - SOA (start of authority) record used for that
    - if SOA number higher on primary, transfer to secondary initiated

### exploitation

- zonefile can be replicated to a unauth. sec. server, if dns server is misconfigured

`host -t NS [zonetransfer.me](http://zonetransfer.me)` → query the nameserver(s)

`host -l zonetransfer.me [nsztm2.digi.ninja](http://nsztm2.digi.ninja)` → dump the transferred zonefile, containing all DNS entries

```bash
❯ host -l zonetransfer.me nsztm2.digi.ninja
Using domain server:
Name: nsztm2.digi.ninja
Address: 34.225.33.2#53
Aliases:

zonetransfer.me has address 5.196.105.14
zonetransfer.me name server nsztm1.digi.ninja.
zonetransfer.me name server nsztm2.digi.ninja.
14.105.196.5.IN-ADDR.ARPA.zonetransfer.me domain name pointer www.zonetransfer.me.
asfdbbox.zonetransfer.me has address 127.0.0.1
canberra-office.zonetransfer.me has address 202.14.81.230
dc-office.zonetransfer.me has address 143.228.181.132
deadbeef.zonetransfer.me has IPv6 address dead:beaf::
email.zonetransfer.me has address 74.125.206.26
home.zonetransfer.me has address 127.0.0.1
internal.zonetransfer.me name server intns1.zonetransfer.me.
internal.zonetransfer.me name server intns2.zonetransfer.me.
intns1.zonetransfer.me has address 81.4.108.41
intns2.zonetransfer.me has address 52.91.28.78
office.zonetransfer.me has address 4.23.39.254
ipv6actnow.org.zonetransfer.me has IPv6 address 2001:67c:2e8:11::c100:1332
owa.zonetransfer.me has address 207.46.197.32
alltcpportsopen.firewall.test.zonetransfer.me has address 127.0.0.1
vpn.zonetransfer.me has address 174.36.59.154
www.zonetransfer.me has address 5.196.105.14
```

**using dig**

`dig -t axfr zonetransfer.me @nameserver`

AXFR = full zone transfer

→ reveals more information than host, e.g. including the TTL

```bash
❯ dig -t axfr zonetransfer.me @nsztm2.digi.ninja

; <<>> DiG 9.18.19 <<>> -t axfr zonetransfer.me @nsztm2.digi.ninja
;; global options: +cmd
zonetransfer.me.        7200    IN      SOA     nsztm1.digi.ninja. robin.digi.ninja. 2019100801 172800 900 1209600 3600
zonetransfer.me.        300     IN      HINFO   "Casio fx-700G" "Windows XP"
zonetransfer.me.        301     IN      TXT     "google-site-verification=tyP28J7JAUHA9fw2sHXMgcCC0I6XBmmoVi04VlMewxA"
zonetransfer.me.        7200    IN      MX      0 ASPMX.L.GOOGLE.COM.
zonetransfer.me.        7200    IN      MX      10 ALT1.ASPMX.L.GOOGLE.COM.
zonetransfer.me.        7200    IN      MX      10 ALT2.ASPMX.L.GOOGLE.COM.
zonetransfer.me.        7200    IN      MX      20 ASPMX2.GOOGLEMAIL.COM.
zonetransfer.me.        7200    IN      MX      20 ASPMX3.GOOGLEMAIL.COM.
zonetransfer.me.        7200    IN      MX      20 ASPMX4.GOOGLEMAIL.COM.
zonetransfer.me.        7200    IN      MX      20 ASPMX5.GOOGLEMAIL.COM.
zonetransfer.me.        7200    IN      A       5.196.105.14
zonetransfer.me.        7200    IN      NS      nsztm1.digi.ninja.
zonetransfer.me.        7200    IN      NS      nsztm2.digi.ninja.
_acme-challenge.zonetransfer.me. 301 IN TXT     "2acOp15rSxBpyF6L7TqnAoW8aI0vqMU5kpXQW7q4egc"
_acme-challenge.zonetransfer.me. 301 IN TXT     "6Oa05hbUJ9xSsvYy7pApQvwCUSSGgxvrbdizjePEsZI"
_sip._tcp.zonetransfer.me. 14000 IN     SRV     0 0 5060 www.zonetransfer.me.
14.105.196.5.IN-ADDR.ARPA.zonetransfer.me. 7200 IN PTR www.zonetransfer.me.
asfdbauthdns.zonetransfer.me. 7900 IN   AFSDB   1 asfdbbox.zonetransfer.me.
asfdbbox.zonetransfer.me. 7200  IN      A       127.0.0.1
asfdbvolume.zonetransfer.me. 7800 IN    AFSDB   1 asfdbbox.zonetransfer.me.
canberra-office.zonetransfer.me. 7200 IN A      202.14.81.230
cmdexec.zonetransfer.me. 300    IN      TXT     "; ls"
contact.zonetransfer.me. 2592000 IN     TXT     "Remember to call or email Pippa on +44 123 4567890 or pippa@zonetransfer.me when making DNS changes"
dc-office.zonetransfer.me. 7200 IN      A       143.228.181.132
deadbeef.zonetransfer.me. 7201  IN      AAAA    dead:beaf::
dr.zonetransfer.me.     300     IN      LOC     53 20 56.558 N 1 38 33.526 W 0.00m 1m 10000m 10m
DZC.zonetransfer.me.    7200    IN      TXT     "AbCdEfG"
email.zonetransfer.me.  2222    IN      NAPTR   1 1 "P" "E2U+email" "" email.zonetransfer.me.zonetransfer.me.
email.zonetransfer.me.  7200    IN      A       74.125.206.26
Hello.zonetransfer.me.  7200    IN      TXT     "Hi to Josh and all his class"
home.zonetransfer.me.   7200    IN      A       127.0.0.1
Info.zonetransfer.me.   7200    IN      TXT     "ZoneTransfer.me service provided by Robin Wood - robin@digi.ninja. See http://digi.ninja/projects/zonetransferme.php for more information."
internal.zonetransfer.me. 300   IN      NS      intns1.zonetransfer.me.
internal.zonetransfer.me. 300   IN      NS      intns2.zonetransfer.me.
intns1.zonetransfer.me. 300     IN      A       81.4.108.41
intns2.zonetransfer.me. 300     IN      A       52.91.28.78
office.zonetransfer.me. 7200    IN      A       4.23.39.254
ipv6actnow.org.zonetransfer.me. 7200 IN AAAA    2001:67c:2e8:11::c100:1332
owa.zonetransfer.me.    7200    IN      A       207.46.197.32
robinwood.zonetransfer.me. 302  IN      TXT     "Robin Wood"
rp.zonetransfer.me.     321     IN      RP      robin.zonetransfer.me. robinwood.zonetransfer.me.
sip.zonetransfer.me.    3333    IN      NAPTR   2 3 "P" "E2U+sip" "!^.*$!sip:customer-service@zonetransfer.me!" .
sqli.zonetransfer.me.   300     IN      TXT     "' or 1=1 --"
sshock.zonetransfer.me. 7200    IN      TXT     "() { :]}; echo ShellShocked"
staging.zonetransfer.me. 7200   IN      CNAME   www.sydneyoperahouse.com.
alltcpportsopen.firewall.test.zonetransfer.me. 301 IN A 127.0.0.1
testing.zonetransfer.me. 301    IN      CNAME   www.zonetransfer.me.
vpn.zonetransfer.me.    4000    IN      A       174.36.59.154
www.zonetransfer.me.    7200    IN      A       5.196.105.14
xss.zonetransfer.me.    300     IN      TXT     "'><script>alert('Boo')</script>"
zonetransfer.me.        7200    IN      SOA     nsztm1.digi.ninja. robin.digi.ninja. 2019100801 172800 900 1209600 3600
;; Query time: 370 msec
;; SERVER: 34.225.33.2#53(nsztm2.digi.ninja) (TCP)
;; WHEN: Sat Sep 30 20:35:08 CEST 2023
;; XFR size: 51 records (messages 1, bytes 2141)
```

**dnsrecon** → tool for automated dns lookups & zone transfers

### prevention

- only allow zone transfers from trusted IPs (bind dns)
    
    ```bash
    ACL trusted-servers 
            {  
                173.88.21.10; // ns1  
                184.144.221.82; // ns2  
            };
            zone securitytrails.com 
            {  
                type master;   file "zones/zonetransfer.me"; 
                allow-transfer { trusted-servers; };  
            };
    ```
    
- transaction signatures



# Firewall (zones & network segmentation)

# Firewalld

Host firewall package

- enables itself after installtion
- leaves port TCP/22 open and close everything else → default
- different zones possible

Interfaces can be assigned to different zones

e.g. `eth0` → `public`

e.g. `eth1` → `internal`

Config file: `/etc/firewalld/firewalld.conf`

no rules in there! → `zones`

`firewall-cmd --permanent --add-port=80/tcp`

→ allow port 80 permanently

`firewall-cmd --reload`

→ apply changes

`firewall-cmd --permanent --remove-port=80/tcp`