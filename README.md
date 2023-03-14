# Bank Leumi CCoE Job Exercise

## VM setup instructions

1. Download the debian Live Bullseye (11) standard ISO (debian-live-11.6.0-amd64-standard.iso) from [debian.org](https://www.debian.org/CD/).
2. Install VirtualBox.
3. Setup a Host-Only Network in VirualBox.
4. Setup the VM similar to the instructions at [ubuntu-server-lab](https://markkerry.github.io/posts/2022/02/ubuntu-server-lab/) specifically the [Configuring-VirtualBox](https://markkerry.github.io/posts/2022/02/ubuntu-server-lab/#configure-virtualbox) section.
5. Power on the VM and select "start debian live" at the Grub menu.
6. configure the VM:
   1. `sudo apt update`
   2. `sudo apt install -y ssh openssh-server iptables ufw`
   3. `sudo systemctl status sshd` 
   4. if `sshd` is not running (is inactive) run: `sudo systemctl start sshd` then check via [3] above.
   5. set ssh to start on reboot: `sudo systemctl enable ssh`
   6. allow ssh through the firewall: `sudo ufw allow ssh`
   7. find the ip address via `ip a` taking care to check for the bridged network interface!
   8. disable the swap file!

<!-- 7. find the current user's name: `echo "${USER}"`
   1. delete the current user's password: `sudo passwd -d ${USER}`
   2. reset the current user's password (and record the new one!): `sudo passwd ${USER}` -->

## Documentation for some of the ansible playbook's code

1. ...
2. https://alta3.com/blog/singlevmk8s
3. https://docs.tigera.io/calico/3.25/getting-started/kubernetes/quickstart

## Additional Documentation used for EC2 User Data setup

- https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
