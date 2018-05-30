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

## Setting up the root certificate
To make sure all traffic to Hyperion's services is securely encrypted, we use TLS for most communication protocols.
Since we self-signed our certificate, you need to install that certificate on your local machine in order for it to trust the server.
To install the root certificate, follow the guides below.

### Windows
In the .zip file you received you will find a ca.crt file.
Right-click it and select "Install certificate".
When prompted, select the following options:

- Store location: local machine
- Place all certificates in the following store: selected
- Click Browser and select **Trusted Root Certificate Authorities**.

Click Finish.

Make sure to restart Docker after installing the certificate to make sure it's known in the Docker daemon as well, otherwise you won't be able to push images.

### MacOS
Double-click on the ca.crt file that you can find in the .zip file you received.
Keychain Access will open with the Add Certificate window.
When asked which keychain to add the certificate to, select the System keychain from the pull-down window.
You will be prompted for your administrator password.

The next window asks whether or not you want the computer to trust certificates from this CA in the future.
Here you must select the trust settings for this CA.
Expand the Trust section and choose "Always Trust" for both "X.509 Basic Policy" and the "When using this certificate" pull-down.
Finally, click the "Always Trust" button.
Provide the administrator password again and the System keychain will be updated.

Make sure to restart Docker after installing the certificate to make sure it's known in the Docker daemon as well, otherwise you won't be able to push images.

### Linux
Copy the ca.crt file that you can find in the .zip file you received to `/etc/docker/certs.d/10.8.0.1:30000/ca.crt` on your Docker host or add the ca.crt file to your trusted CA store (`/etc/pki/ca-trust/source/anchors/hyperion.crt` on CentOS, `/usr/local/share/ca-certificates` on Ubuntu).
When you do the latter, make sure to reload your certificates (`sudo update-ca-trust extract` for CentOS, `sudo update-ca-certificates` for Ubuntu).
Make sure to restart Docker after installing the certificate to make sure it's known in the Docker daemon as well, otherwise you won't be able to push images.

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
1. Install [Tunnelblick](https://tunnelblick.net/)
2. Open the `<username>.ovpn` file with Tunnelblick and connect.

### Linux
1. `yum install openvpn` / `apt-get install openvpn`
1. `openvpn --config client.ovpn`


## Setting up SFTP for file transfer
To upload files to the cluster and to download files from it, you need to use SFTP.
You can only connect to SFTP if you are connected to the VPN, so make sure you've set that up first.

1. On Windows, MacOS and Linux, it's easiest to use FileZilla, which can be downloaded [here](https://filezilla-project.org/download.php?type=client) or on Linux it can be installed with your package manager of choice.
1. Start FileZilla, and click File -> Site Manager.
1. In the Site Manager, add a New Site and name it "Hyperion".
1. Use the following details:
   * Host: **10.8.0.1**
   * Port: **22**
   * Protocol: **SFTP - SSH File Transfer Protocol**
   * Logon Type: **Key file**
   * User: **your Hyperion Linux user name** (usually initials + last name, like `sreitsma` or `djlemkes`)
   * Key file: **the `id_ed25519` file** in the .zip file you received from the administrators. Make sure NOT to select the `id_ed25519.pub` file!
   * All other settings can be kept at their **defaults**
1. Connect!
In the future you can connect quickly by selecting Hyperion in the dropdown menu in the top-left of FileZilla.
If everything worked correctly, you should now see some directories like `.ssh` and `keys` in the folder browser on the right.

## Setting up Kubernetes
To submit jobs, you need to setup the kubectl configuration.
Kubectl is the application that communicates with a Kubernetes cluster and allows you to start, stop and monitor jobs.

First, let's install kubectl.

---

### Windows
On Windows you have three options:
* If you have WSL (Bash for Ubuntu for Windows) up and running, just use that and follow the Ubuntu guide below.
If you don't have WSL this might be a good time to set it up
* You can install kubectl using PSGallery or Chocolatey (both package managers for Windows).
* You can download kubectl.exe [here](https://github.com/eirslett/kubectl-windows/releases) if you don't have any of the package managers mentioned above. You can then place this file somewhere convenient and add it to your path.
### MacOS
Check out [this guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-with-homebrew-on-macos).
### Linux
Check out [this guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-native-package-management).

---

Now, let's setup the kubectl configuration using the `config` file in your .zip file.
Again, please note that the `config` file contains your Kubernetes credentials, so make sure not to share it with others.

### Windows
If you're using WSL you can follow the Linux guide below.
If you used PSGallery, Chocolatey or downloaded the binary yourself, you should create a directory `C:\Users\<user>\.kube\` and copy the `config` file that you can find in the .zip file into that directory.
If the file already exists, you can overwrite it.

### MacOS
Place the `config` file from the .zip file in `~/.kube/`.

### Linux
Place the `config` file from the .zip file in `~/.kube/`.

---

You should now execute `kubectl cluster-info` in your terminal to check if you can successfully connect to the cluster.
Again, you need to be connected to the VPN to connect to the Kubernetes cluster.
