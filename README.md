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
In development, probably a combination of:
- Polyaxon
- Docker
- Kubernetes
- Helm
- (Slurm)

This repository will in time contain all deployment scripts, configuration files and documentation for using the box.

Provisioning
--------

We provision our machines using Ansible.
To start a full provisioning of Hyperion, run the following command:

`ansible-playbook -i inventory --ask-vault-pass provision_from_scratch.yml`

This will ask you for an Ansible Vault password, which is shared offline between administrators.
Ansible provisioning should always be done as the `admin` user with public key authentication.
The private key and its associated passphrase are also shared offline.
In short, before you can start provisioning, you need someone to give you the following:

1. The Ansible Vault password
1. The `admin` private key
1. The `admin` private key passphrase

Before being able to kick-off the provisioning scripts, it is assumed you have done everything mentioned in Preprocessing.md.