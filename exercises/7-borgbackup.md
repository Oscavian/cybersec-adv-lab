# BorgBackup

> We are looking for a backup solution that has the following advantages:
> 
> - Backups can be automated. This way, backups won't be forgotten.
> - Backups are immutable. Once backed up, the data cannot be changed. Cloud syncing (OneDrive, Google Drive, DropBox, MEGA, ...) or RAID are not backups! Why? Can you think of a malware attack that demonstrates this?
> - Backups are encrypted.
> - Backups can be done to a remote machine (preferably through existing technologies such as SSH and SFTP).
> - Backups are incremental. Only delta's are stored between backups following each other. E.g. If only 1 byte has changed of the 100 GB of data, it has no use to keep 2 times a full backup of 100GB. Just store the full data with the initial backup and then store what has changed between backups (the so called deltas). This greatly saves storage space and allows you to have a lot of backups that represent different snapshots in time of your data.
> - It is possible to have a retention policy. E.g. although that you take a backup every week, you can specify that only the last 20 backups must be kept and 1 for every month for the last 2 years and 1 for every year for older backups. All the rest will be automatically cleaned up every time you make a backup, what greatly reduces storage space.
> - Deduplication is supported. The backup data is split in blocks and a hash for each block is created and stored. If multiple blocks have the same hash, they are identical. There is no need to store these blocks multiple times, just store it once, and the similar blocks will just link to the actual block. This can also greatly reduce storage space.
> - It is possible to verify if backups are corrupted.
> - It easy to retrieve the data stored in backups.
> - The software is trusted and tested!

**Files to be backupped:**

    A video file you can download from https://video.blender.org/download/videos/bf1f3fb5-b119-4f9f-9930-8e20e892b898-720.mp4
    2 text files you can download from ...
        https://www.gutenberg.org/ebooks/100.txt.utf-8
        https://www.gutenberg.org/ebooks/996.txt.utf-8
    An audio fragment you can dowload from https://upload.wikimedia.org/wikipedia/commons/4/40/Toreador_song_cleaned.ogg

## Steps

### Preperation

```sh
# web
mkdir ~/important-files

curl --location --remote-name-all https://video.blender.org/download/videos/bf1f3fb5-b119-4f9f-9930-8e20e892b898-720.mp4 https://www.gutenberg.org/ebooks/100.txt.utf-8 https://www.gutenberg.org/ebooks/996.txt.utf-8 https://upload.wikimedia.org/wikipedia/commons/4/40/Toreador_song_cleaned.ogg


## add SSH key for remote auth
ssh-keygen -t ed25519
ssh-copy-id oskar@172.30.0.15
```
```sh
# database
mkdir ~/backups
```
```sh
# both
## enable epel repo
sudo dnf config-manager --set-enabled crb
sudo dnf install epel-release

sudo dnf install borgbackup
```

- the `web` machine needed 1G RAM instead of 512M.

`curl` options:
- `--remote-name-all` - uses the original remote filename as output filename for all given resources
  - leaving it out outputs the response to `stdout`
  - confusingly, it seems to automatically follow HTTP redirects even if the `--location` option wasn't specified
- `--location` - curl will follow `3XX` redirects with a new request
  - if left out, only the html containing the `3XX` message will be outputted.

### Creating the repository

```sh
# web
borg init --encryption repokey oskar@172.30.0.15:~/backups

borg key export oskar@172.30.0.15:~/backups
```
```
# ~/borg.key
BORG_KEY 625def55cb0a6307369cf2f48b61193c47747abcefdccc0f58d7f02ca7ed59c0
hqlhbGdvcml0aG2mc2hhMjU2pGRhdGHaAN412I9aL+zihb33dAOdDrsDdGdaoFzSju5n7R
icY6M+0PgeapoA4RVqRiT4vnW/mlCKP5HTwr5i4rxlR9eRhfifAuaCWmtp7VBHauNmVd6v
VKp24/rjQvE1/C/SbFJKRc+3yzG/S5jeyrctyQ0iLlzS+djoEtPp41hJ9MbjsS8dNwXBl1
75yKaHwwIVPOM2swlrn4n2VaWgj4HdtzgnmlWfmikDJyq9S1EvKWJLvIzYoS+j51lktIA1
B7tbUen2ufOxKj4Rco+r3e3U7/j8LwQcXlhW4wucSs0fNe5wEVmkaGFzaNoAIHWlemEo6s
QniM74RpLKZE/elsd9cXCoy0JVnwt1TLacqml0ZXJhdGlvbnPOAAGGoKRzYWx02gAgC4E5
AvWwOySMLOkJB+LiGagw4w26irgUeQIkEfIhcg2ndmVyc2lvbgE=
```

## First backup

```sh
borg create -C zlib oskar@172.30.0.15:~/backups::first ~/important-files
```

```sh
[oskar@web ~]$ borg info oskar@172.30.0.15:~/backups
Enter passphrase for key ssh://oskar@172.30.0.15/~/backups:
Repository ID: 625def55cb0a6307369cf2f48b61193c47747abcefdccc0f58d7f02ca7ed59c0
Location: ssh://oskar@172.30.0.15/~/backups
Encrypted: Yes (repokey)
Cache: /home/oskar/.cache/borg/625def55cb0a6307369cf2f48b61193c47747abcefdccc0f58d7f02ca7ed59c0
Security dir: /home/oskar/.config/borg/security/625def55cb0a6307369cf2f48b61193c47747abcefdccc0f58d7f02ca7ed59c0
------------------------------------------------------------------------------
                       Original size      Compressed size    Deduplicated size
All archives:              120.65 MB            115.38 MB            115.38 MB

                       Unique chunks         Total chunks
Chunk index:                      45                   45
```

## Another backup

```sh
$ borg create oskar@172.30.0.15:~/backups::second ~/important-files

$ borg list oskar@172.30.0.15:~/backups
first                                Mon, 2024-01-08 20:56:02 [7bcb412e1b561b5b4f0a5c18ea5e548867b853bf4e728bf6470cc7bb06265e4e]
second                               Mon, 2024-01-08 21:01:17 [7eafaa1e4720bf1967292377c43bb34432813fe4aab6fc0e04009b2fc7c13a8e]
```

```
[oskar@web ~]$ borg list oskar@172.30.0.15:~/backups::second
Enter passphrase for key ssh://oskar@172.30.0.15/~/backups:
Enter passphrase for key ssh://oskar@172.30.0.15/~/backups:
drwxr-xr-x oskar  oskar         0 Mon, 2024-01-08 21:00:53 home/oskar/important-files
-rw-r--r-- oskar  oskar        12 Mon, 2024-01-08 21:00:53 home/oskar/important-files/test.txt
-rw-r--r-- oskar  oskar   5638564 Mon, 2024-01-08 20:26:31 home/oskar/important-files/100.txt.utf-8
-rw-r--r-- oskar  oskar   2391726 Mon, 2024-01-08 20:26:32 home/oskar/important-files/996.txt.utf-8
-rw-r--r-- oskar  oskar  110916740 Mon, 2024-01-08 20:26:29 home/oskar/important-files/bf1f3fb5-b119-4f9f-9930-8e20e892b898-720.mp4
-rw-r--r-- oskar  oskar   1702187 Mon, 2024-01-08 20:26:32 home/oskar/important-files/Toreador_song_cleaned.ogg
```

## Inspection

> With which bash command can you see the size of the folder with the files on the webserver? How big is that folder? Tip: try with and without the --si option. Which corresponds with the output of borg? Where do you find this in the BorgBackup documentation?

`du -h important-files/` shows the disk usage:
```
[oskar@web ~]$ du -h --si important-files/
121M    important-files/
[oskar@web ~]$ du -h important-files/
116M    important-files/
```

Omitting the `--si` option corresponds to the borg output. The `du` man page says, `--si` changes the base to `10` (MB) instead of `2` (MiB)

Borg documentation: https://borgbackup.readthedocs.io/en/stable/usage/general.html#units

> Now check the size of the backups folder on the database server.

[oskar@database ~]$ du -h backups/data/
111M    backups/data/0

> What is the difference between Original size, Compressed size and Deduplicated size? Can you link this with the sizes you found for the folders on the web and db VM's? Make sure you comprehend this!

- Borg info output (two backups made)
```
                       Original size      Compressed size    Deduplicated size
All archives:              241.30 MB            230.76 MB            115.39 MB
```

- backup disk usage in MB (base 10)
```sh
[oskar@database ~]$ du -h --si backups/data/
116M    backups/data/0
```
**Conclusion:** Borg apparently displays its disk usage in base 10!

**Original Size**: File sizte without deduplication, as if every backup was a full backup

**Compressed Size**: Original files, made smaller by an compression algorithm e.g. zlib.

**Deduplicated Size**: Removes files that did not change in a new backup revision compared to the older one, safes a lot of space.2

> What are chunks?

Borg splits files into chunks and calculates their hashsum. Therefore it can determine which files have been changed and need to be backed up. Meaning only the chunks with a non-familiar hash get added to the repository.

## Checking Integrity

```sh
# only checks consistency of repo itself
borg check oskar@172.30.0.15:~/backups

# also checking consistency and correctness of the archive metadata and optionally archive data
borg check --verify-data oskar@172.30.0.15:~/backups
```

## Deleting & Restoring

```sh
# delete from web
rm -rvf important-files/

# restore first archive
borg extract --strip-components 2 oskar@172.30.0.15:~/backups::first ~
```

## Automating backups

**Grandfather-Father-Son policy**:
- Monthly full backup, stored off-site -> gradfather
- Weekly full backup, stored locally or in cloud -> father
- Daily incrementatl backup stored in same place as father -> son

**Retention policy:** how many backups from which type to keep

**`borg compact`**: remove deleted objects from the repository

Taking [this](https://borgbackup.readthedocs.io/en/stable/quickstart.html#automating-backups) script as a baseline, I created a sample backup script [here](../scripts/borg.sh).

Automation with systemd-timers works the following way:

- create a systemd unit and place it at `/etc/systemd/system/importantbackup.service`
```sh
[Unit]
Description=Run important backup

[Service]
# systemd does not run scripts within a home directory, so i had to move it
ExecStart=/opt/borg.sh
User=oskar
Type=oneshot
```

- create a systemd timer at `/etc/systemd/system/importantbackup.timer`
```sh
[Unit]
Description=Run importantbackup every 5 minutes

[Timer]
OnCalendar=*:0/5

[Install]
WantedBy=timers.target
```

```sh
# start the timer 
sudo systemctl start importantbackup.timer

# view timers
systemctl list-timers
```

- the output of `journalctl -feu importantbackup` should look like:
```
Jan 08 22:40:42 web systemd[1]: Starting Run important backup...
Jan 08 22:40:42 web borg.sh[18222]: Mon Jan  8 22:40:42 UTC 2024 Starting backup
Jan 08 22:40:42 web borg.sh[18224]: Creating archive at "oskar@172.30.0.15:~/backups::web-2024-01-08T22:40:42"
Jan 08 22:40:42 web borg.sh[18224]: A /home/oskar/important-files/Toreador_song_cleaned.ogg
Jan 08 22:40:42 web borg.sh[18224]: ------------------------------------------------------------------------------
Jan 08 22:40:42 web borg.sh[18224]: Repository: ssh://oskar@172.30.0.15/~/backups
Jan 08 22:40:42 web borg.sh[18224]: Archive name: web-2024-01-08T22:40:42
Jan 08 22:40:42 web borg.sh[18224]: Archive fingerprint: a2fe615240208590a7ec6ee9184a167c4d3cbae6897772e55b93ec543c245a0a
[...]
```