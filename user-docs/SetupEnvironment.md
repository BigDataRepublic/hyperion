# Setting up your environment
This page will explain you how to setup your local development environment to use the Hyperion cluster.
We use Kubernetes for queueing jobs, and as such you will be able to upload your own Docker containers to the cluster.
This enables you to run any application you want, with a few exceptions.

## Getting an account on the cluster
To get an account on the Hyperion cluster, you need to request it from an administrator.
Currently, the administrators are Bram, Diederik and Steven.
You can use the hyperion@bigdatarepublic.nl address to contact them.
When the administrators create an account for you, you will have multiple user contexts:

- A Linux account on the cluster (by default without SSH access)
- Your own folder to upload and download files using SFTP
- A VPN account
- Your own namespace in Kubernetes
- A user account on Kubernetes
- A service account on Kubernetes

From the administrators, you will receive an encrypted .zip file with access keys for all of these contexts:

- An SSH key to connect to SFTP (no terminal access, only for uploading/downloading files)
- An OpenVPN configuration file (with embedded user credentials) to connect to the VPN
- A kubectl configuration file (with embedded user credentials) to connect to Kubernetes

In this documentation page, we will show you how to setup access to all of these services.

## Setting up the VPN
We run an OpenVPN server on Hyperion.
You need to connect to this VPN to access any of Hyperion's services, even if you're at the office!
You should be able to connect to the VPN from every device with a working internet connection.
To setup your OpenVPN connection, complete the following steps using the .ovpn file in the .zip you received.
The .ovpn file contains your VPN credentials so make sure to store it securely.

### Windows
1. To connect to the VPN on Windows, first install OpenVPN.
You can find the installer [here](https://openvpn.net/index.php/open-source/downloads.html).
1. In the .zip file you received from the Hyperion administrators, you will find a .ovpn file. Extract it and place it in `C:\Users\<user>\OpenVPN\config\hyperion\<user>.ovpn`. If these directories do not yet exist, you can create them.
3. Right-click the OpenVPN GUI in your task tray and click "Connect" to immediately get connected to the VPN.

### MacOS
TODO

### Linux
1. `yum install openvpn` / `apt-get install openvpn`
1. `openvpn --config client.ovpn`


## Setting up SFTP for file transfer
To upload files to the cluster and to download files from it, you need to use SFTP.
You can only connect to SFTP if you are connected to the VPN, so make sure you've set that up first.

### Windows
1. On Windows, it's easiest to use FileZilla, which can be downloaded [here](https://filezilla-project.org/download.php?type=client).
1. Start FileZilla, and click File -> Site Manager.
1. In the Site Manager, add a New Site and name it "Hyperion".
1. Use the following details:
   * Host: 10.8.0.1
   * Port: 22
   * Protocol: SFTP - SSH File Transfer Protocol
   * Logon Type: Key file
   * User: your Hyperion Linux user name (usually initials + last name, like `sreitsma` or `djlemkes`)
   * Key file: the `id_ed25519` file in the .zip file you received from the administrators. Make sure NOT to select the `id_ed25519.pub` file!
   * All other settings can be kept at their defaults
1. Connect!
In the future you can connect quickly by selecting Hyperion in the dropdown menu in the top-left of FileZilla.
If everything worked correctly, you should now see some directories like `.ssh` and `keys` in the folder browser on the right.

## Setting up Kubernetes
