Hyperion
========
[_God of Watchfulness, Wisdom and the Light_](https://en.wikipedia.org/wiki/Hyperion_%28mythology%29)

Hyperion is our brand-new GPU-powered server that we use for our deep learning experiments.

Hardware
--------
- GPU: NVIDIA Titan Xp (Jedi Collector's Edition)
- CPU: AMD Ryzen Threadripper 1900x (8 cores, 4GHz)
- RAM: G.Skill Trident Z 32GB
- Motherboard: Asus Prime X399-A
- SSD: Samsung EVO 960 NVMe
- Tons of harddisk storage
- Watercooled

TODO: insert picture here

Software
--------
Access via WAN/LAN:
- OpenVPN

Access via Tunnel:
- KubeCTL
- SFTP, no SSH, key based authentication
- probably more

Local LAN:
- Ports 8000-9000 for docker jobs, notebooks etc.

Rules and regulation
--------------------
The following things are prohibited:
- Crypto mining
- Anything considered not safe for work
- Storing or using customer data
- Facilitate WAN facing services (e.g. [IPFS](https://ipfs.io/))


Provisioning
--------

We provision our machines using Ansible.
To start a full provisioning of Hyperion, run the following command:

`ansible-playbook -i inventory --ask-vault-pass -u <USER_NAME> provision_from_scratch.yml`

This will ask you for an Ansible Vault password, which is shared offline between administrators.
Ansible provisioning should always be done as your personal user with public key authentication.
In short, before you can start provisioning, you need someone to give you the following:

1. The Ansible Vault password
1. The private key to your user account, if you don't have this already
1. Membership to the `administrators` Linux group. Other administrators can facilitate this.

Before being able to kick-off the provisioning scripts, it is assumed you have done everything mentioned in Preprocessing.md.

Refreshing kubelet certificates
--------
https://github.com/kubernetes/kubeadm/issues/581#issuecomment-421477139
