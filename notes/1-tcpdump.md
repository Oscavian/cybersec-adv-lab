## TCPdump

<aside>
💡 TODO

</aside>

https://www.youtube.com/watch?v=KTvuyN1QGqs

https://www.youtube.com/watch?v=hWc-ddF5g1I

`-c` number of packets to capture

`-D` view every interfaces tcpdump has access to

`-i <int>`  specify interface to listen on

`-n` show ip instead of hostnames

`-XX` display hex and ascii

`-A` display ascii data

`-t` dont display timestamp, `-tt` display unix ts, `-ttt` relative time, `-tttt` include date

     eg. `tcpdump -i eth0`

### Filters

by hosts

`host <hostname>` show only packets from and to that host

`host src/dst <hostname/ip/mac>` show only packets originating from/arriving at

 by networks

`net <ip> <subnetmask>` 

by ports

`port <nr>`

combine filters

`host 10.0.0.1 and/or [not] port 22`

by protocol

`arp/icmp/...`

### Output file

`-w /tmp/out.pcap -c 25` 

read pcap:

`-r /path/to/file`

### PCAP expressions

`man pcap-filter`

---