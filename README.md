# RHEL VM Setup Scripts

Cross-platform scripts for automated RHEL virtual machine creation and configuration. Supports both Linux (libvirt/KVM) and macOS (UTM).

## Features

- **Cross-platform**: Automatically detects and uses the appropriate virtualization platform
  - Linux: libvirt/KVM
  - macOS: UTM (QEMU backend)
- **Automated Setup**: Creates fully configured VMs with:
  - Red Hat subscription registration
  - User account creation with SSH key authentication
  - mDNS/Avahi for easy network access via `<hostname>.local`
  - Automatic SSH known_hosts configuration
- **Cloud-init Based**: Uses cloud-init for VM provisioning, ensuring cross-platform compatibility
- **Efficient Storage**: Uses QCOW2 backing files on Linux to minimize disk usage

## Prerequisites

### Linux (libvirt/KVM)
- `virsh`, `virt-install`, `qemu-img`, `xorriso`
- libvirtd running with user permissions: `virsh -c qemu:///system list`
- RHEL KVM image (x86_64) downloaded to `~/.local/share/rhelmcp/rhel-X.Y-x86_64-kvm.qcow2`

### macOS (UTM)
- UTM.app installed at `/Applications/UTM.app` ([Download](https://mac.getutm.app/))
- `osascript`, `hdiutil` (built-in to macOS)
- RHEL ARM64 image downloaded to `~/.local/share/rhelmcp/rhel-X.Y-aarch64-kvm.qcow2`

### Both Platforms
- SSH key at `~/.ssh/id_ed25519.pub` or `~/.ssh/id_rsa.pub` (ed25519 preferred)
- Configuration file at `~/.config/rhelmcp/config.env` (see Configuration section)

## Installation

### Adding mcpvm to Your PATH

To use `mcpvm` from anywhere, create a symlink in a directory on your PATH:

```bash
mkdir -p ~/bin
ln -s /path/to/mcp-vm-scripts/tools/mcpvm ~/bin/mcpvm
```

Ensure `~/bin` is in your PATH (add to `~/.bashrc` or `~/.zshrc` if needed):
```bash
export PATH="$HOME/bin:$PATH"
```

### Shell Completion

#### Bash

Add to your `~/.bashrc`:
```bash
source /path/to/mcp-vm-scripts/tools/mcpvm-bash-completion.sh
```

#### Zsh

Add to your `~/.zshrc`:
```bash
source /path/to/mcp-vm-scripts/tools/mcpvm-zsh-completion.zsh
```

Or place in your `$fpath` as `_mcpvm` for standard zsh completion loading.

## Configuration

Create `~/.config/rhelmcp/config.env` with your Red Hat subscription details:

```bash
# Get these from: https://console.redhat.com/insights/connector/activation-keys
REDHAT_ORG_ID=1234567
REDHAT_ACTIVATION_KEY=myuser-rhelmcp
```

## Usage

```bash
./tools/mcpvm <command> [options]
```

### Creating a VM

```bash
./tools/mcpvm setup --version=<RHEL-VERSION> [--playbook=<PATH>] [NAME]
```

**Examples:**
```bash
# Create a VM with auto-generated name (e.g., mcpvm-rustic-spatula)
./tools/mcpvm setup --version=9.5

# Create a VM with a specific name
./tools/mcpvm setup --version=9.5 mcpvm-my-test

# Create a VM and run an Ansible playbook after setup
./tools/mcpvm setup --version=9.5 --playbook=configure.yml
```

**Note:** All VM names must start with `mcpvm-`. If no name is provided, a random name is generated in the format `mcpvm-<adjective>-<utensil>`.

The setup command will:
1. Validate prerequisites for your platform (Linux or macOS)
2. Check that the base RHEL image exists
3. Create a cloud-init ISO with:
   - VM hostname configuration (`<NAME>.local`)
   - Red Hat subscription registration
   - User account (current user) with sudo access
   - SSH authorized key
   - Avahi/mDNS setup
4. Create the VM using platform-specific tools:
   - **Linux**: Creates VM disk with backing file, uses `virt-install`
   - **macOS**: Passes base image to UTM, which copies it into VM bundle via AppleScript
5. Wait for VM to boot and acquire an IP address
6. Configure SSH known_hosts for immediate passwordless access
7. Optionally run an Ansible playbook (if `--playbook` specified)
8. Display connection instructions

## Connecting to VMs

After creation, connect via:
```bash
ssh <username>@<NAME>.local
```

Where `<username>` is your current system username.

## Managing VMs

Use `mcpvm` commands for cross-platform VM management:

```bash
# List all mcpvm-managed VMs
./tools/mcpvm list

# Stop a VM
./tools/mcpvm stop mcpvm-my-test

# Start a stopped VM
./tools/mcpvm start mcpvm-my-test

# Delete a VM and its resources
./tools/mcpvm delete mcpvm-my-test
```

### Platform-Specific Console Access

For console access, use platform-specific tools:

**Linux (libvirt):**
```bash
virsh -c qemu:///system console <NAME>
```

**macOS (UTM):**
Open UTM.app and click on the VM to view its console.

## Architecture

### File Structure
- `tools/mcpvm` - Main entry point with subcommand dispatch
- `tools/lib/common.sh` - Common utilities (logging, validation, SSH, Ansible)
- `tools/lib/cloudinit.sh` - Cloud-init ISO generation (cross-platform)
- `tools/lib/platform-libvirt.sh` - Linux/libvirt implementation
- `tools/lib/platform-utm.sh` - macOS/UTM implementation
- `tools/lib/applescript/run-vm-utm.scpt` - AppleScript helper for UTM VM creation
- `tools/lib/applescript/get-vm-ip-utm.scpt` - AppleScript helper for UTM IP lookup

### Design Principles
- Platform abstraction through function naming convention (`platform_*`)
- Cloud-init for provisioning (avoids platform-specific guest modification)
- Shared network configuration for easy host access
- mDNS/Avahi for DNS-less hostname resolution

## Downloading RHEL Images

Download RHEL KVM Guest Images from:
https://access.redhat.com/downloads/content/rhel

- **Linux**: Download x86_64 KVM image
- **macOS**: Download ARM64 (aarch64) image

Place downloaded images at:
- **Linux**: `~/.local/share/rhelmcp/rhel-X.Y-x86_64-kvm.qcow2`
- **macOS**: `~/.local/share/rhelmcp/rhel-X.Y-aarch64.qcow2`
