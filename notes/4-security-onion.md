# Security Onion

> https://docs.securityonion.net/en/2.4/introduction.html

**Introduction to Security Onion:**

- **Purpose:** Free and open platform designed by defenders for defenders.
- **Components:**
  - Network visibility
  - Host visibility
  - Intrusion detection honeypots
  - Log management
  - Case management

**Network Visibility:**

- **Components:** 
  - Signature-based detection (Suricata)
  - Protocol metadata (Zeek/Suricata)
  - Full packet capture (Stenographer)
  - File analysis (Strelka)
  
**Intrusion Detection:**

- **Function:** Generates NIDS alerts via Suricata by monitoring network traffic for anomalies.

**Host Visibility:**

- **Components:**
  - Elastic Agent for data collection
  - Live queries via osquery
  - Centralized management with Elastic Fleet

**Analysis Tools:**

- **Security Onion Console (SOC):**
  - Alerts interface
  - Dashboards for overview
  - Hunt for threat-focused queries
  - Cases for case management
  - Full packet capture (PCAP) interface

- **CyberChef:** Decoding, decompressing, and analyzing artifacts

- **Playbook:** Creation of Detection Playbook with individual plays

**Workflow:**

- Review Alerts -> Dashboards -> Hunt -> PCAP -> CyberChef
- Escalate to Cases, develop plays in Playbook, update coverage in ATT&CK Navigator
- Utilize Elastic Agent for host queries
- Document investigation in Cases and close the case

**Deployment Scenarios:**

- Security Onion Setup wizard for flexible deployment configurations

**Conclusion:**

- Comprehensive network and host visibility for enterprise security and intrusion detection.
