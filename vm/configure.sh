# Post-installation steps
apt update -y && apt upgrade -y
apt install -y dialog linux-azure locales-all curl wget nano htop fping git \
  firewalld ca-certificates ubuntu-drivers-common ufw apt-transport-https

# Base configuration
hostnamectl set-hostname
timedatectl set-timezone EST5EDT
ufw default deny incoming && ufw default allow outgoing
ufw allow ssh && ufw enable && ufw reload

# Configure Hyper-V
mkdir /usr/libexec/hypervkvpd/
ln -s /usr/sbin/hv_get_dhcp_info /usr/libexec/hypervkvpd/hv_get_dhcp_info
ln -s /usr/sbin/hv_get_dns_info /usr/libexec/hypervkvpd/hv_get_dns_info
/usr/libexec/hypervkvpd/hv_get_dhcp_info && /usr/libexec/hypervkvpd/hv_get_dns_info
echo "blacklist hv_balloon" >> /etc/modprobe.d/blacklist-hv_balloon.conf

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
