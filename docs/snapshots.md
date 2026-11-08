# Snapshots and USB backup

The laptop takes automatic "photos" of your files, and a USB stick holds a copy of those photos somewhere else. If you break or delete something, you pick an older photo and copy the file back.

Scripts: [`setup/snapshots.sh`](../setup/snapshots.sh) (laptop snapshots) and [`setup/backup-usb.sh`](../setup/backup-usb.sh) (USB copy).

## The idea in plain words

A **snapshot** is a photo of what every file looked like at one moment. Taking one is instant. At first it uses almost no space, because it only keeps the parts of files that change afterwards.

The catch: snapshots sit on the same disk as your files. If that disk dies, or the laptop is lost or stolen, the snapshots go with it. That is what the **USB stick** is for. It is locked with a passphrase, so if you lose it, nobody can read what is on it.

```
┌─ Laptop disk ─────────────────────────────┐
│  If this disk dies, all of this goes      │
│                                           │
│  Your files                               │      backup-usb.sh       ┌─ USB stick ───────────────┐
│  System photos     every update, last 10  │  ─────── by hand ──────▶ │  Last 8 backups of both   │
│  Home photos       hourly, about a month  │                          │  Locked with a passphrase │
└───────────────────────────────────────────┘                          └───────────────────────────┘
```

- **Snapshots on the laptop:** automatic. Quick undo for mistakes and bad updates.
- **Backups on the USB stick:** you run them by hand. They save you when the laptop itself is gone.

## What gets saved and when

| What | When a photo is taken | How many are kept | Where it lives |
| --- | --- | --- | --- |
| System files (`/`): installed apps, settings in `/etc` | Just before and just after every `dnf` update or install | The last 10 updates | Laptop, in `/.snapshots` |
| Your home folder (`/home`): documents, downloads, configs | Every hour | 12 hourly, 7 daily, 4 weekly (about a month back) | Laptop, in `/home/.snapshots` |
| Both of the above | Each time you run the USB backup | The last 8 backups | USB stick |

Old photos are deleted automatically, so they never fill the disk.

One thing is never in a photo: the boot files in `/boot`, which hold the kernel that starts the computer. Fedora keeps the last 3 kernels in the boot menu instead (see scenario 4).

## One-time setup

Four steps, done once, in this order. Use a normal terminal window, because they ask for passwords. Start in the repo folder: `cd ~/swaywm`.

1. **Turn on snapshots:** `./setup/snapshots.sh` (or `./install.sh --with-snapshots`)
    - Asks for your login password (sudo).
    - Installs the snapshot tool (snapper) and starts the hourly and update photos.
2. **Find the stick's name:** `lsblk`
    - Look for the disk marked `usb` with `RM` set to 1, for example `/dev/sdb`. The name can change when you replug it.
    - The Fedora disk may be on USB too. The next step refuses to touch it, but check anyway.
3. **Prepare the stick:** `./setup/backup-usb.sh --init /dev/sdb`
    - **This erases everything on the stick.**
    - It asks you to type the device path, then `YES` in capitals, then a new passphrase twice.
    - **Write the passphrase down somewhere safe, away from the laptop.** Without it, nobody can open the backup, including you.
4. **First backup:** `./setup/backup-usb.sh`
    - Copies everything, so this one is slow. On a cheap stick, about 16 GB took a few hours. Later backups only copy what changed and take minutes.

## Making a backup to the stick

Nothing happens automatically: if you don't run it, the stick goes stale.

1. Plug in the stick.
2. Run `cd ~/swaywm && ./setup/backup-usb.sh`
3. Type your login password, then the stick's passphrase.
4. Wait for `Done. Safe to unplug once this exits.` and unplug.

It also prints how full the stick is.

**How often:** once a week is a good habit. Also back up before anything big, such as upgrading to the next Fedora version.

**While it runs:** keep the charger in and the lid open. Closing the lid suspends the laptop and pauses the copy. Ctrl+C is safe; the next run cleans up the half-finished copy.

## Scenarios: what went wrong, what to do

For anything less than a month old, try the laptop first: it is faster and needs no stick.

| # | What happened | Get it back from |
| --- | --- | --- |
| 1 | Deleted or broke a file in the last month | Laptop snapshots |
| 2 | Need a file older than a month | USB stick |
| 3 | A software update broke something | Laptop snapshots |
| 4 | The computer won't start after an update | Boot menu |
| 5 | The disk died, or the laptop is lost or stolen | USB stick |
| 6 | Lost the USB stick | Nothing to restore |
| 7 | Forgot the stick's passphrase | Nothing to restore |

In the commands below, replace numbers like `42` with the snapshot or backup number you picked.

### 1. Deleted or broke a file in the last month

1. List the photos of your home folder with their dates: `snapper -c home list`
2. Pick the number from just before the mistake, say `42`.
3. Look inside it. It shows your home folder exactly as it was: `ls /home/.snapshots/42/snapshot/ashish/`
4. Copy the file back: `cp -a /home/.snapshots/42/snapshot/ashish/path/to/file ~/path/to/file`

No password is needed for your own files. You can also browse `/home/.snapshots` in a file manager.

### 2. Need a file older than a month

1. Plug in the stick, go to `~/swaywm` and unlock it: `./setup/backup-usb.sh --mount`
2. See the backups. Each folder is one backup, and the highest number is the newest: `ls /run/snapbackup/home/`
3. Copy the file out: `cp -a /run/snapbackup/home/57/snapshot/ashish/path/to/file ~/path/to/file`
4. Lock it again before unplugging: `./setup/backup-usb.sh --umount`

### 3. A software update broke something

1. List the system photos: `snapper -c root list`
2. Find the `pre` and `post` pair whose description shows the update command, for example `120` and `121`.
3. See what it changed (optional): `snapper -c root status 120..121`
4. Undo everything that update changed: `sudo snapper -c root undochange 120..121`
5. Restart: `sudo reboot`

The list of installed packages is rolled back too, so `dnf` stays in sync.

### 4. The computer won't start after an update

1. Restart. When the boot menu appears, pick the second entry, which is the previous kernel.
2. Once you are back on the desktop, follow scenario 3 to undo the update.

The boot files are not in snapshots, so the boot menu is the undo for a bad kernel.

### 5. The disk died, or the laptop is lost or stolen

This is what the stick is for. Your files come back, and the system is rebuilt from this repo rather than copied.

1. **Install Fedora** on the new disk. Create the same username, `ashish`.
2. **Switch to a text screen** with Ctrl+Alt+F3 and log in. Copying your home folder from inside the desktop is messy.
3. **Unlock the stick.** The script is inside the backup, so this uses plain commands:
    - `sudo cryptsetup open /dev/disk/by-partlabel/snapbackup snapbackup`
    - `sudo mkdir -p /mnt/usb && sudo mount /dev/mapper/snapbackup /mnt/usb`
4. **Pick the newest backup:** `ls /mnt/usb/home`
5. **Copy your home folder back:**
    - `sudo rsync -aHAX --info=progress2 /mnt/usb/home/57/snapshot/ /home/`
    - `sudo restorecon -R /home` (fixes Fedora's security labels on the copied files)
6. **Rebuild the system** from the repo that just came back: `cd ~/swaywm && ./install.sh --with-snapshots --with-sddm`
7. **Copy back any system settings you miss** from `/mnt/usb/root/<number>/snapshot/`. For example, saved Wi-Fi networks are in `etc/NetworkManager/system-connections/`.
8. **Start fresh on the stick:** once everything works, follow steps 2 to 4 of the one-time setup.

The old system folder is not copied back whole. The new install has different disk IDs and boot files, so an old copy would not start.

### 6. Lost the USB stick

Nothing is exposed, because the stick is locked with your passphrase. Get a new stick, then follow steps 2 to 4 of the one-time setup with it.

### 7. Forgot the stick's passphrase

The backups on it cannot be opened by anyone, and there is no recovery. While the laptop still works, erase the stick and start over: follow steps 2 to 4 of the one-time setup. This time, write the passphrase down.

## Practice once

After your first backup, restore one unimportant file from the stick. It takes two minutes, and it proves the passphrase, the stick and these steps all work before you need them.

- [ ] Run the first backup
- [ ] Unlock the stick with `--mount` and copy one file out (scenario 2)
- [ ] Lock it again with `--umount`
- [ ] Store the passphrase somewhere safe, away from the laptop

## Cheat sheet

Run the `./setup/...` commands from `~/swaywm`.

| To do this | Run |
| --- | --- |
| See home folder photos | `snapper -c home list` |
| See system photos | `snapper -c root list` |
| Back up to the stick | `./setup/backup-usb.sh` |
| Open the stick to browse | `./setup/backup-usb.sh --mount` |
| Lock the stick | `./setup/backup-usb.sh --umount` |
| Undo a software update | `sudo snapper -c root undochange PRE..POST` |
| Find the stick's device name | `lsblk` |

### Words used here

| Word | Meaning |
| --- | --- |
| Snapshot | A photo of your files at one moment, kept on the laptop |
| Backup | A copy kept on a different device, here the USB stick |
| snapper | The tool that takes and cleans up snapshots |
| btrfs | The way Fedora stores files on the disk; it is what makes instant snapshots possible |
| dnf | Fedora's app installer and updater |
| Passphrase | The password that locks the stick (LUKS encryption) |
| sudo | Runs a command as administrator; asks for your login password |
