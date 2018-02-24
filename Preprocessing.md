Installing the OS
=====

We use a minimal CentOS booted from a Live USB stick. The settings that are used are the following:

- Auto partitioning, with the root partition (/) set to 25GiB and the rest of the disk set as /home.
- Admin user should be named `admin`

Admin user setup
=====
- add an SSH key for `admin` and add it to its `authorized_keys` file
- add `admin    ALL=(ALL)	NOPASSWD: ALL` to the `/etc/sudoers` file to make sure Ansible does not prompt for a password

Mounting the hard drives
=====
Partitioning is a one time job for new hard disks, you do not need to do this for existing disks.
To partition a new hard drive, do the following:

1. Find the dev map to your hard disk, e.g. `/dev/sda`
1. Start `parted /dev/sda`
1. Create a GPT table by doing `mklabel GPT`
1. Create a primary partition, correctly aligned, spanning 100% of the disk `mkpart primary 2048s 100%`
1. `quit`
1. Format the filesystem by doing `mkfs.ext4 /dev/sda1`
1. Create a mounting directory `mkdir /mnt/hdd`
1. `cat "/dev/sda1       /mnt/hdd        ext4    defaults        0 0" >> /etc/fstab`