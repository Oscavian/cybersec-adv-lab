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
> 
> https://docs.ansible.com/ansible/latest/os_guide/windows_winrm.html

```sh
# necessary module
pip install pywinrm
```

- create a LOCAL administrator account machines

```ps1
$username = "ansible";
$password = ConvertTo-SecureString "ansible" -AsPlainText -Force
New-LocalUser -Name "$username" -Password $password -FullName "$username" -Description "local Ansible user";
Add-LocalGroupMember -Group "Administrators" -Member "$username";
```


### Testing

```sh
# nope :(
ansible -i inventory.yaml -m "win_ping" dc

# Yes ^o^
ansible -i inventory.yaml -m "win_ping" win10
win10 | SUCCESS => {
    "changed": false,
    "invocation": {
        "module_args": {
            "data": "pong"
        }
    },
    "ping": "pong"
}

# Yes ^o^
ansible -i inventory.yaml -m "win_shell" -a "hostname" win10
win10 | CHANGED | rc=0 >>
win10
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

> Create a playbook (or ad-hoc command) that pulls all "/etc/passwd" files from all Linux machines locally to the ansible controller node for every machine seperately.

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

> Create a playbook (or ad-hoc command) that creates the user "walt" with password "Friday13th!" on all Linux machines.

> https://docs.ansible.com/ansible/latest/reference_appendices/faq.html#how-do-i-generate-encrypted-passwords-for-the-user-module

```sh
# create password hash
python -c "from passlib.hash import sha512_crypt; import getpass; print(sha512_crypt.using(rounds=5000).hash(getpass.getpass()))"
```

```yaml
- name: Create user walt
  hosts: linux_hosts
  tasks:
    - name: Create user walt
      ansible.builtin.user:
        name: walt
        password: $6$OE/uJN.QD8SLCso4$O5XDzUhJpJq1jHUn4.rvntSyvKgE6gCIitbww54becu3B7/Rn8ZGC6NyaAd..Tkb3suy5563TpPxleDSZCsCg. # '123456'
        state: present
```
```sh
ansible -i inventory.yaml linux_hosts -m ansible.builtin.user -a 'name=walt password="$6$OE/uJN.QD8SLCso4$O5XDzUhJpJq1jHUn4.rvntSyvKgE6gCIitbww54becu3B7/Rn8ZGC6NyaAd..Tkb3suy5563TpPxleDSZCsCg." state=present'
```

> Create a playbook (or ad-hoc command) that pulls all users that are allowed to log in on all Linux machines.

```yaml
- hosts: linux_machines
  tasks:
    - name: Get allowed login users
      shell:
        cmd: cat /etc/passwd | grep '/bin/bash' | cut -d: -f1
```
```sh
ansible -i inventory.yaml linux_hosts -m shell -a "cat /etc/passwd | grep '/bin/bash' | cut -d: -f1"
```

> Create a playbook (or ad-hoc command) that calculates the hash (md5sum for example) of a binary (for example the ss binary).

```sh
ansible -i inventory.yaml linux_hosts -m command -a "md5sum $(which ss)"
```

> Create a playbook (or ad-hoc command) that shows if Windows Defender is enabled and if there are any folder exclusions configured on the Windows client. This might require a bit of searching on how to retrieve this information through a command/PowerShell.

https://learn.microsoft.com/en-us/powershell/module/defender/get-mpcomputerstatus?view=windowsserver2022-ps

https://learn.microsoft.com/en-us/powershell/module/defender/get-mppreference?view=windowsserver2022-ps

```sh
ansible -i inventory.yaml win10 -m "win_shell" -a "Get-MpComputerStatus; Get-MpPreference | Select-Object -ExpandProperty ExclusionPath"
```

> Create a playbook (or ad-hoc command) that copies a file (for example a txt file) from the ansible controller machine to all Linux machines.

```sh
ansible -i inventory.yaml linux_hosts -m copy -a "src=./test.txt dest=/opt/ mode='0644' owner=root group=root"
```

- Create the same but for Windows machines.

```sh
ansible -i inventory.yaml win10 -m win_copy -a "src=test.txt dest=C:\\Users\\oskar\\"
```