Installing the OS
=====

We use a minimal CentOS booted from a Live USB stick. A [kickstarter file](./anaconda-ks.cfg) that contains the root password, partition schema and more is included in this repository. You can either add it to the CentOS installation image as `/ks.cgh` or use the pre-baked image on the [BDR GDrive](https://drive.google.com/open?id=1JDp-jNBWAClOMtFTDsFI2WaZwPPPLE8j).

The root password is shared with those who need access via Lastpass.

Kickstarter file option documentation and more can be found at [Redhat](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/installation_guide/s1-kickstart2-options).

Provisioning the bootable image
=====
The steps below have been used successfully on a Ubuntu (17) machine. We have not been able to reproduce on Mac and Windows. Steps are taken from [this](https://serverfault.com/questions/517908/how-to-create-a-custom-iso-image-in-centos) Serverfault page.

1. Download the [CentOS 7 minimal image](http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1708.iso)
2. Create a temp dir: `mkdir /tmp/bootiso`
3. Loop mount the source ISO you are modifying: `mount -o loop /path/to/some.iso /tmp/bootiso`
4. Create a working directory for your customized media: `mkdir /tmp/bootisoks`
5. Copy the source media to the working directory: `cp -r /tmp/bootiso/* /tmp/bootisoks/`
6. Unmount the source ISO and remove the directory: `umount /tmp/bootiso && rmdir /tmp/bootiso`
7. Change permissions on the working directory: `chmod -R u+w /tmp/bootisoks`
8. Copy the kickstart file to the mounted iso: `cp /path/to/anaconda-ks.cfg /tmp/bootisoks/isolinux/ks.cfg`
9. Add kickstart to boot options: `sed -i 's/append\ initrd\=initrd.img/append initrd=initrd.img\ ks\=cdrom:\/ks.cfg/' /tmp bootisoks/isolinux/isolinux.cfg`
10. Create the new ISO file: `cd /tmp/bootisoks && mkisofs -o /tmp/boot.iso -b isolinux.bin -c boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -V "CentOS 7 x86_64" -R -J -v -T isolinux/. .`
11. Add an MD5 checksum (to allow testing of media): `implantisomd5 /tmp/boot.iso`
12. Isohybrid the file to prepare it for a bootable USB key: `isohybrid /tmp/boot.iso`
13. Copy the file to an USB stick using either `dd if=/tmp/boot.iso of=/dev/your-usb-dev` or an app like [Etcher](https://etcher.io/)
14. (Optional) upload the new version of the image to the [BDR GDrive](https://drive.google.com/open?id=1JDp-jNBWAClOMtFTDsFI2WaZwPPPLE8j) for future use.