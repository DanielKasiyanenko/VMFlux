# VMFlux, Automated VM Deployment with Packer and Terraform

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Packer](https://img.shields.io/badge/Packer-1.9+-blue.svg)](https://www.packer.io/)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-purple.svg)](https://www.terraform.io/)
[![RHEL](https://img.shields.io/badge/RHEL-9-red.svg)](https://www.redhat.com/en/technologies/linux-platforms/enterprise-linux)

> A complete automation workflow for building and deploying secure virtual machines with Secure Boot enabled, developed during an internship at Piros NV. This project reduces VM deployment time from 3 hours to 15 minutes with 100% Secure Boot compliance.

## 🚀 Overview

This project provides a comprehensive Infrastructure as Code (IaC) solution for automating the creation and deployment of virtual machines across multiple Linux distributions. The workflow combines Packer for image building and Terraform for infrastructure provisioning, specifically designed for enterprise environments requiring Secure Boot compliance and automated deployment pipelines.

**Development Status:**
- ✅ **RHEL9**: Complete and fully operational with Secure Boot implementation
- ⚠️ **Debian**: Template exists but is incomplete and not fully operational
- ⚠️ **openSUSE**: Template exists but is incomplete and not fully operational

### Key Features

- **Multi-Distribution Support**: Templates for RHEL9, Debian, and openSUSE (RHEL9 production-ready)
- **Secure Boot Implementation**: UEFI/OVMF firmware with Secure Boot enabled by default
- **Dual Platform Deployment**: Support for both libvirt/KVM and Proxmox environments
- **Parallel Processing**: Support for up to 20 concurrent VM builds
- **Cloud-init Integration**: Automatic user setup, network configuration, and disk expansion
- **Reproducible Builds**: Identical VM configurations across deployments

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Platform Support](#platform-support)
- [Usage](#usage)
- [Deployment Targets](#deployment-targets)
- [Performance Metrics](#performance-metrics)
- [Security Features](#security-features)
- [Contributing](#contributing)
- [Troubleshooting](#troubleshooting)
- [Project Background](#project-background)
- [Acknowledgments](#Acknowledgments)
- [Support](#support)

## 🛠️ Prerequisites

### Required Software
- **Packer** >= 1.9.0
- **Terraform** >= 1.5.0
- **QEMU/KVM** with hardware virtualization support
- **libvirt** (for local development)
- **Proxmox** (for production deployment)

### System Requirements
- Linux host with KVM support
- Minimum 8GB RAM (16GB recommended for parallel builds)
- 50GB+ available disk space
- Network connectivity for ISO downloads and package updates

### Access Requirements
- RHEL9 ISO image or access to Red Hat repositories
- Proxmox server access (for production deployment)
- libvirt daemon running (for local testing)

## 🚀 Quick Start

1. **Clone the repository**
```bash
git clone https://github.com/DanielKasiyanenko/VMFlux.git
cd VMFlux
```

2. **Build RHEL9 image (recommended)**
```bash
cd packer-image-builder/rhel9
packer build rhel9.pkr.hcl
```

3. **Deploy with Terraform**
```bash
# For libvirt/KVM deployment
cd terraform-vm-builder/libvirt
terraform init
terraform apply

# For Proxmox deployment
cd terraform-vm-builder/proxmox
terraform init
terraform apply
```

## 📁 Project Structure

```bash
VMFlux/
├── packer-image-builder/
│   ├── rhel9/                          # RHEL9 templates (complete)
│   │   ├── rhel9.pkr.hcl               # Main Packer template
│   │   ├── http/                       # Kickstart files
│   │   └── scripts/                    # Post-install scripts
│   ├── debian/                         # Debian templates (incomplete)
│   └── opensuse/                       # openSUSE templates (incomplete)
└── terraform-vm-builder/
    ├── libvirt/                        # libvirt/KVM deployment
    └── proxmox/                        # Proxmox deployment
```

## 🖥️ Platform Support

### Production Ready
- **RHEL9**: Fully operational automation workflow
  - ✅ Secure Boot with OVMF firmware
  - ✅ Kickstart-based automated installation
  - ✅ Cloud-init integration
  - ✅ HTTP server for Kickstart delivery
  - ✅ Custom post-installation scripts

### In Development (Contributions Welcome)
- **Debian**: Basic Packer template structure exists
- ⚠️ Preseed configuration incomplete
- ⚠️ Cloud-init integration pending
- ⚠️ Testing and validation required

- **openSUSE**: Basic Packer template structure exists
- ⚠️ AutoYaST configuration incomplete
- ⚠️ Package selection needs refinement
- ⚠️ Secure Boot integration pending

## 🔧 Usage

### Building Images

**RHEL9 (Production Ready)**
```bash
cd packer-image-builder/rhel9
# Edit variables as needed
packer build rhel9.pkr.hcl
```

**Development Distributions**
```bash
# These are available but not complete
cd packer-image-builder/debian
packer build debian.pkr.hcl  # May fail - incomplete

cd packer-image-builder/opensuse
packer build opensuse.pkr.hcl  # May fail - incomplete
```

### Deployment Options

**Local Development with libvirt**
```bash
cd terraform-vm-builder/libvirt
terraform init
terraform plan
terraform apply
```

**Production Deployment with Proxmox**
```bash
cd terraform-vm-builder/proxmox
terraform init
terraform plan
terraform apply
```

## 🎯 Deployment Targets

### libvirt/KVM
- **Use Case**: Local development and testing
- **Features**: Direct KVM integration, local storage
- **Benefits**: Fast iteration, no external dependencies

### Proxmox
- **Use Case**: Production enterprise deployment
- **Features**: Web UI integration, enterprise features
- **Benefits**: High availability, backup integration, monitoring

## 📊 Performance Metrics

Achieved performance improvements with the RHEL9 implementation:

- **Deployment Time**: Reduced from 3 hours to 15 minutes (92% improvement)
- **Parallel Builds**: Support for 20 concurrent VM builds
- **Success Rate**: 100% Secure Boot compliance
- **Automation Level**: Fully unattended deployment process

## 🔒 Security Features

### RHEL9 Implementation
- **Secure Boot**: Enabled by default with UEFI firmware
- **Minimal Installation**: Only essential packages included
- **Automated Updates**: Latest security patches applied during build
- **Network Security**: Configurable firewall rules
- **User Management**: Automated user creation with SSH key deployment

## 🤝 Contributing

Contributions are especially welcome for completing the Debian and openSUSE implementations!

### Priority Areas
- **Debian**: Complete preseed configuration and cloud-init integration
- **openSUSE**: Finish AutoYaST configuration and Secure Boot setup
- **Documentation**: Improve setup guides and troubleshooting
- **Testing**: Add automated testing for all distributions

### Development Process
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/complete-debian`)
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Current Limitations
- Debian template exists but preseed configuration is incomplete
- openSUSE template exists but AutoYaST needs completion
- Only RHEL9 has been fully tested in production environments

## 🔍 Troubleshooting

### Common Issues

**VNC Connection Problems**
```hcl
# Ensure VNC is properly configured in Packer templates
headless = false
vnc_bind_address = "0.0.0.0"
```

**Secure Boot Configuration**
- Verify OVMF firmware paths are correct
- Check hardware virtualization support
- Ensure proper UEFI settings in template

**Network Issues During Build**
```bash
# Check libvirt network setup
sudo virsh net-list --all
sudo virsh net-start default
```

## 📚 Project Background

This project was developed during an internship at Piros NV, a Belgian IT company specializing in Red Hat open-source solutions. The goal was to create a fully automated VM deployment pipeline that reduces manual intervention and improves security compliance through Secure Boot implementation.

### Technical Achievements
- Integrated OVMF firmware for Secure Boot support
- Implemented cloud-init with growpart for automatic disk expansion
- Created dual-platform deployment supporting both libvirt and Proxmox
- Achieved 92% reduction in deployment time through automation

## Acknowledgments

- **Piros NV** for providing the internship opportunity and technical guidance
- **Indy Van Mol** (Piros NV) for project mentorship and technical support
- **Pieter Hollevoet** (UCLL) for academic supervision
- **HashiCorp** for Packer and Terraform tools
- **Red Hat** for RHEL9 and comprehensive documentation

## 📞 Support

For questions, issues, or contributions:

- 🐛 **Issues**: [GitHub Issues](https://github.com/DanielKasiyanenko/VMFlux/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/DanielKasiyanenko/VMFlux/discussions)
- 📧 **Contact**: daniel2000@live.be

---

**Note**: This project focuses primarily on RHEL9 implementation with production-ready features. Debian and openSUSE templates are included for future development but are not currently complete or fully operational. Contributions to complete these implementations are highly welcome!
