Installing the OS
=====

We use a minimal CentOS booted from a Live USB stick. You can kickstart the installation by copying `anaconda-ks.cfg` to the flash drive containing the CentOS installation image as `/ks.cfg` (i.e. in the root level, named `ks.cfg`).

Admin user setup
=====
- Add an SSH key for `admin` and add it to its `authorized_keys` file. This is only for initial provisioning. As soon as your personal user account is created that account should be used.
- Add `administrators    ALL=(ALL)	NOPASSWD: ALL` to the `/etc/sudoers` file to make sure Ansible does not prompt for a password for admin users

The admin user is only for physical access to the machine and for the initial provisioning.

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
