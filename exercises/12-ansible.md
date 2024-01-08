# Ansible Hunting & Hardening

## Installing Ansible

```sh
sudo dnf install python3-pip
pip3 install --user ansible
```

## Adding new ansible ssh key

```sh
ssh-keygen -t ed25519 ~/.ssh/id_ansible
ssh-copy-id -i ~/.ssh/id_ansible.pub user@host
```

## Creating an inventory

[Inventory](../ansible/inventory.yaml)

## Configuring windows hosts

> https://docs.ansible.com/ansible/latest/os_guide/windows_setup.html

### Testing

```sh
ansible -i inventory.yaml -m "win_ping" dc

ansible -i inventory.yaml -m "win_shell" -a "hostname" dc

ansible -i inventory.yaml -m "ping" linux
```

## Sample Use cases


- Run an ad-hoc ansible command to check if the date of all machines are configured the same. Are you able to use the same Windows module for Linux machines and vice versa?

```sh
# Linux
ansible all -m command -a "date"
database | CHANGED | rc=0 >>
Sat Jan  6 18:50:07 UTC 2024
web | CHANGED | rc=0 >>
Sat Jan  6 18:50:07 UTC 2024
companyrouter | CHANGED | rc=0 >>
Sat Jan  6 18:50:07 UTC 2024
```

- Create a playbook (or ad-hoc command) that pulls all "/etc/passwd" files from all Linux machines locally to the ansible controller node for every machine seperately.

```yaml
---
# Playbook
- name: Fetch passwd files
  hosts: linux_hosts
  tasks:
    - name: Copy /etc/passwd file
      ansible.builtin.fetch:
        src: /etc/passwd
        dest: "./passwd/{{ inventory_hostname }}/"
        flat: true
```
```sh
ansible -i inventory.yaml linux_hosts -m ansible.builtin.fetch -a "src=/etc/passwd dest=./passwd/passwd_{{ inventory_hostname }} flat=yes"
```

- Create a playbook (or ad-hoc command) that creates the user "walt" with password "Friday13th!" on all Linux machines.
- Create a playbook (or ad-hoc command) that pulls all users that are allowed to log in on all Linux machines.
- Create a playbook (or ad-hoc command) that calculates the hash (md5sum for example) of a binary (for example the ss binary).
- Create a playbook (or ad-hoc command) that shows if Windows Defender is enabled and if there are any folder exclusions configured on the Windows client. This might require a bit of searching on how to retrieve this information through a command/PowerShell.
- Create a playbook (or ad-hoc command) that copies a file (for example a txt file) from the ansible controller machine to all Linux machines.
- Create the same as 7 but for Windows machines.
