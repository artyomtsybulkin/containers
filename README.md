# Containers

This repository contains resources and scripts related to containerized environments, focusing on automated Hyper-V VM provisioning and Ubuntu Server setup for Docker instance hosting.

---

## Host Installation

- **Ubuntu Server Download:**  
  [Official ISO](https://ubuntu.com/download/server)  
  [Custom Images](https://github.com/canonical/ubuntu-image)

- **Docker Engine Installation:**  
  [Docker for Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

---

## VM & OS Setup Checklist

- [x] **Base System:** Hyper-V virtual machine
- [x] **Operating System:** Ubuntu Server LTS
- [x] **Language/Layout:** English (US)
- [x] **Install Mode:** Ubuntu Server (minimized)
- [x] **Storage:** Disable LVM during installation
- [x] **Filesystem:** Use XFS instead of ext4
- [x] **OpenSSH:** Enable during setup

---

## Notes

- The provided PowerShell script automates VM creation and clustering for Hyper-V.
- Adjust installation steps as needed for your environment.

## Hyper-V Automation

- Hyper-V VM Provisioning Script: [`New-DockerVM.ps1`](./New-DockerVM.ps1)  
  Automates the creation and clustering of a new Hyper-V virtual machine for Ubuntu Server and Docker workloads.

- Ubuntu Post-Install Configuration Script:
  [`configure.sh`](./configure.sh)  
  Automates essential post-installation steps on Ubuntu Server, such as system updates, Docker installation, and basic configuration for container workloads.
  