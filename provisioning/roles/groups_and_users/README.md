Groups and users
=====

This role creates the following groups:

- administrators
- developers

and creates users for each BDR employee.
User details are stored in `vars/main.yml` and are encrypted using Ansible Vault.
New users can be added to the list in `vars/main.yml` and will automatically have their ED25519 SSH keys generated without a passphrase.
The private key can then be shared by an administrator with the user.
Users should change their keys after logging in for the first time.
