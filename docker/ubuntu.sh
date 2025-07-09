

# Post-installation steps
apt update -y && apt upgrade -y

# Fix this issue:
# debconf: unable to initialize frontend: Dialog
# debconf: (No usable dialog-like program is installed, so the dialog based frontend cannot be used. at /usr/share/perl5/Debconf/FrontEnd/Dialog.pm line 79.)
# debconf: falling back to frontend: Readline
apt install -y dialog

# Install base packages
apt install -y linux-azure locales-all curl wget nano htop fping git firewalld
apt install -y ca-certificates
apt upgrade -y ubuntu-drivers-common

# Base configuration
hostnamectl set-hostname
timedatectl set-timezone EST5EDT

# Install nginx
apt install -y nginx nginx-extras

# Cleanup for docker
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Images, containers, volumes, and networks stored in /var/lib/docker/ aren't automatically removed when you uninstall Docker

# Add Docker's official GPG key:
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update

apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Configure Hyper-V
mkdir /usr/libexec/hypervkvpd/
ln -s /usr/sbin/hv_get_dhcp_info /usr/libexec/hypervkvpd/hv_get_dhcp_info
ln -s /usr/sbin/hv_get_dns_info /usr/libexec/hypervkvpd/hv_get_dns_info
/usr/libexec/hypervkvpd/hv_get_dhcp_info && /usr/libexec/hypervkvpd/hv_get_dns_info
echo "blacklist hv_balloon" >> /etc/modprobe.d/blacklist-hv_balloon.conf

# Firewall
# Remember Docker bypass iptables by default
apt install ufw
ufw default deny incoming && ufw default allow outgoing
ufw allow ssh && ufw enable && ufw reload

# 1password
curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
  gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg && \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
  tee /etc/apt/sources.list.d/1password.list && \
  mkdir -p /etc/debsig/policies/AC2D62742012EA22/ && \
  curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
  tee /etc/debsig/policies/AC2D62742012EA22/1password.pol && \
  mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22 && \
  curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
  gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg && \
  apt update && apt install -y 1password-cli
