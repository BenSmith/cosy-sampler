# SELinux Policies

⚠️ **Example SELinux policy modules - not critical-environment security policies**

These SELinux policy modules demonstrate different security approaches for cosy containers. SELinux provides mandatory access control and is highly complex - these examples are for reference only.

## ⚠️ Critical Warnings

- **Requires SELinux expertise** - Don't use these unless you understand SELinux policy development
- **Not maintained** - SELinux policies require updates as systems and applications change
- **System-specific** - Policies may not work on your distribution or configuration
- **Potentially insecure** - Incorrect SELinux policies can reduce security or break functionality
- **No support provided** - These reflect personal usage patterns, not security best practices

**If you don't know what these do, don't use them.**

## Why a Separate Repository from [cosy](https://github.com/BenSmith/cosy)?

### I am not a security expert. 
Even if I was, I can't make any guarantee that my policies would match your use cases.

#### SELinux policies are:
- **Complex** - Require specialized knowledge to write and maintain
- **System-specific** - What works on Fedora 39 may not work on RHEL 9 or Fedora 40
- **Rapidly changing** - Require updates as kernels and SELinux evolve
- **High maintenance burden** - Need security expertise to maintain properly, and requirements change frequently
- **Intentional friction** - Making these less convenient than a part of cosy means you have to look at more disclaimers 

For these reasons, they're provided as examples rather than maintained components of cosy.

## Table of Contents

- [Available Policies](#available-policies)
  - [cosy_default_t](#cosy_default_t---default-policy)
  - [cosy_strict_t - Strict Policy](#cosy_strict_t---strict-policy)
  - [cosy_default_systemd_t - Systemd Policy](#cosy_default_systemd_t---default-systemd-policy)
  - [cosy_strict_systemd_t - Strict Systemd Policy](#cosy_strict_systemd_t---strict-systemd-policy)
  - [spc_t - Super Privileged Container (Built-in)](#spc_t---super-privileged-container-built-in)
- [Installation](#installation)
  - [Prerequisites](#prerequisites)
  - [Quick Install (Using `just`)](#quick-install-using-just)
  - [Manual Installation](#manual-installation)
- [Usage](#usage)
- [Uninstallation](#uninstallation)
- [Troubleshooting](#troubleshooting)
- [Customizing Policies](#customizing-policies)
- [Alternatives to These Policies](#alternatives-to-these-policies)
- [Policy Comparison](#policy-comparison)
- [Resources](#resources)

## Available Policies

### `cosy_default_t` - Default Policy

A balanced policy that provides good security while enabling full functionality for typical desktop applications.

**Permissions:**
- ✅ Read/write X11 and Wayland sockets
- ✅ Audio access (PulseAudio/PipeWire)
- ✅ Full GPU device access (/dev/dri)
- ✅ Read/write access to container home directory
- ✅ Connect to X server for DRI
- ✅ Podman socket access (when using `--podman` flag)

**Best for:** General-purpose GUI applications, games, creative tools, development environments

### `cosy_strict_t` - Strict Policy

A more restrictive policy suitable for applications that don't need full system access. Provides additional containment with some functionality trade-offs.

**Permissions:**
- ✅ Read-only X11 and Wayland sockets
- ✅ Audio access (PulseAudio/PipeWire)
- ⚠️  Limited GPU access (read/ioctl only, no write)
- ⚠️  Read-only access to host files
- ✅ Read/write in container home (via :Z label)
- ✅ Podman socket access (when using `--podman` flag - use with caution)

**Best for:** Document viewers, browsers, lightweight applications

**Note:** The `--podman` flag grants significant privilege even in strict mode. Only use with trusted applications.

### `cosy_default_systemd_t` - Default Systemd Policy

A systemd-enabled variant of the default policy. Use this when running containers with systemd as init (e.g., `--systemd=always`).

**Permissions:**
- ✅ All permissions from `cosy_default_t`
- ✅ Additional systemd-specific capabilities (filesystem mounting, remounting)
- ✅ Enhanced cgroup access for systemd unit management
- ✅ Extended /proc and /sys access for init system operations

**Best for:** Development environments with systemd, containers needing service management, testing systemd units

### `cosy_strict_systemd_t` - Strict Systemd Policy

A systemd-enabled variant of the strict policy with additional containment for systemd-based containers.

**Permissions:**
- ✅ All permissions from `cosy_strict_t`
- ✅ Limited systemd-specific capabilities
- ✅ Enhanced cgroup access for systemd (read-mostly)
- ✅ Restricted mounting permissions

**Best for:** Systemd-based containers that don't need full system access, isolated services

### `spc_t` - Super Privileged Container (Built-in)

**Security Level:** ★★★☆☆ (Permissive)

The `spc_t` type is built into Fedora/RHEL and doesn't require installation. It's designed for system tools and provides broad permissions.

**Best for:** Development tools, system utilities, when you need maximum compatibility

## Installation

### Prerequisites

- SELinux-enabled system (Fedora, RHEL, CentOS, Rocky, Alma)
- `selinux-policy-devel` package installed
- `just` command runner (optional, or use manual commands)

```bash
# Install prerequisites on Fedora
sudo dnf install just selinux-policy-devel

# Check SELinux is enforcing
getenforce  # Should output: Enforcing
```

### Quick Install (Using `just`)

```bash
# Install just if needed
sudo dnf install just selinux-policy-devel

# Install all policies
cd selinux-policies/
just install

# Or install specific policies
just install-default           # Install cosy_default_t only
just install-strict            # Install cosy_strict_t only
just install-default-systemd   # Install cosy_default_systemd_t only
just install-strict-systemd    # Install cosy_strict_systemd_t only

# Build without installing
just build                     # Build all policies
just build-default             # Build cosy_default_t only
just build-strict              # Build cosy_strict_t only
just build-default-systemd     # Build cosy_default_systemd_t only
just build-strict-systemd      # Build cosy_strict_systemd_t only

# Check installation
just check
```

### Manual Installation

**Important:** SELinux policy installation must be done on the **host system**, not inside a container. If you're developing cosy inside a container, build the `.pp` files in the container and then install them on the host.

```bash
cd selinux-policies/

# Build the policy modules
make -f /usr/share/selinux/devel/Makefile cosy_default_t.pp
make -f /usr/share/selinux/devel/Makefile cosy_strict_t.pp
make -f /usr/share/selinux/devel/Makefile cosy_default_systemd_t.pp
make -f /usr/share/selinux/devel/Makefile cosy_strict_systemd_t.pp

# Install on the host (must be run outside container)
sudo semodule -i cosy_default_t.pp
sudo semodule -i cosy_strict_t.pp
sudo semodule -i cosy_default_systemd_t.pp
sudo semodule -i cosy_strict_systemd_t.pp

# Verify installation
semodule -l | grep cosy
```

## Usage

### Using Built-in `spc_t` (No Installation Required)

```bash
# Create a container with spc_t policy
cosy create --security-opt label=type:spc_t myapp

# Enter the container
cosy enter myapp

# Or run a one-off command with spc_t
cosy run myapp firefox
```

### Using `cosy_default_t`

```bash
# Create a container with default policy
cosy create --security-opt label=type:cosy_default_t --audio --gpu myapp

# Run applications
cosy enter myapp
# or
cosy run myapp gimp
```

### Using `cosy_strict_t`

```bash
# Create a container with strict policy
cosy create --security-opt label=type:cosy_strict_t myapp

# Run applications
cosy enter myapp
# or
cosy run myapp firefox
```

### Using `cosy_default_systemd_t`

```bash
# Create a systemd container with default systemd policy
# Note: --systemd=always auto-enables, or use an image with /usr/sbin/init as CMD
cosy create --security-opt label=type:cosy_default_systemd_t --systemd always --image fedora:43 myapp

# Enter the container
cosy enter myapp
```

### Using `cosy_strict_systemd_t`

```bash
# Create a systemd container with strict systemd policy
cosy create --security-opt label=type:cosy_strict_systemd_t --systemd always --image fedora:43 myapp

# Enter the container
cosy enter myapp
```

### Running Without SELinux Confinement (Default)

```bash
# By default, containers run without SELinux confinement
cosy create myapp

# To explicitly disable SELinux for a container (using podman's native option)
cosy create --security-opt label=disable myapp
```

## Uninstallation

### Using `just`

```bash
cd selinux-policies/

# Uninstall all policies
just uninstall

# Or uninstall specific policies
just uninstall-default
just uninstall-strict
just uninstall-default-systemd
just uninstall-strict-systemd
```

### Manual Uninstallation

```bash
sudo semodule -r cosy_default_t
sudo semodule -r cosy_strict_t
sudo semodule -r cosy_default_systemd_t
sudo semodule -r cosy_strict_systemd_t
```

## Troubleshooting

### Check if a Policy is Installed

```bash
semodule -l | grep cosy
```

### View SELinux Denials

```bash
# Recent denials
sudo ausearch -m avc -ts recent

# Denials for a specific container
sudo ausearch -m avc -ts recent | grep <container-name>
```

### Generate Policy from Denials

If you encounter permission errors, you can generate policy rules from audit logs:

```bash
# Run your container and trigger the denial
cosy run --security-opt label=type:cosy_default_t myapp app

# Generate policy suggestions
sudo ausearch -m avc -ts recent | audit2allow -m mycosy

# Or create and install a custom module (advanced)
sudo ausearch -m avc -ts recent | audit2allow -M mycosy
sudo semodule -i mycosy.pp
```

### Check SELinux Labels on Mounts

```bash
# Check a running container's mount labels
podman inspect <container-name> | grep -A2 "Source.*X11"
```

## Customizing Policies

You can create your own custom policies based on the provided templates:

1. Copy one of the existing `.te` files:
   ```bash
   cp cosy_default_t.te my_custom_t.te
   ```

2. Edit the policy (change module name and rules):
   ```bash
   policy_module(my_custom_t, 1.0.0)
   # ... modify rules ...
   ```

3. Build and install:
   ```bash
   checkmodule -M -m -o my_custom_t.mod my_custom_t.te
   semodule_package -o my_custom_t.pp -m my_custom_t.mod
   sudo semodule -i my_custom_t.pp
   ```

4. Use with cosy:
   ```bash
   cosy create --security-opt label=type:my_custom_t myapp
   ```

## Alternatives to These Policies

Instead of using these example policies, consider:

1. **Use system defaults** - Podman's default SELinux labeling (`container_t`) works well for most use cases
2. **Use spc_t for privileged containers** - Already provided by `container-selinux` package
3. **Disable labeling for testing** - `--security-opt label=disable` (not for production!)
4. **Create your own** - Based on your specific security requirements and threat model

## Policy Comparison

| Feature | disabled | spc_t | cosy_default_t | cosy_strict_t | cosy_default_systemd_t | cosy_strict_systemd_t |
|---------|----------|-------|----------------|---------------|------------------------|----------------------|
| Installation Required | No | No | **Yes** | **Yes** | **Yes** | **Yes** |
| SELinux Enforcement | ❌ None | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Systemd Support | N/A | Limited | Limited | Limited | ✅ Full | ✅ Full |
| X11/Wayland Access | ✅ Full | ✅ Full | ✅ Full | ⚠️ Read-only | ✅ Full | ⚠️ Read-only |
| GPU Access | ✅ Full | ✅ Full | ✅ Full | ⚠️ Limited | ✅ Full | ⚠️ Limited |
| Audio Access | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full |
| Podman Socket | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes* | ✅ Yes | ✅ Yes* |
| Host File Write | ✅ Yes | ✅ Yes | ✅ Yes | ❌ No | ✅ Yes | ❌ No |
| Container Home Write | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Filesystem Mounting | ✅ Yes | ✅ Yes | ❌ No | ❌ No | ✅ Yes | ⚠️ Limited |
| Audit Logging | ❌ No | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Security Level | ★☆☆☆☆ | ★★★☆☆ | ★★★★☆ | ★★★★★ | ★★★★☆ | ★★★★★ |

*Podman socket access grants significant privilege - use with trusted containers only

## Resources

- [SELinux Project](https://github.com/SELinuxProject/selinux) - Upstream SELinux
- [Fedora SELinux User Guide](https://docs.fedoraproject.org/en-US/quick-docs/selinux-getting-started/)
- [Container SELinux](https://github.com/containers/container-selinux) - Container policy framework
- [Policy writing guide](https://selinuxproject.org/page/PolicyLanguage)

## Disclaimer

These policies are **reference examples only**. They were created for testing cosy's SELinux integration and personal use. They are not:
- Security audited
- Maintained for correctness
- Suitable for critical environments without review and modification
- Guaranteed to work on your system

**Do not use in critical environments without understanding SELinux policy development and auditing these for your specific needs.**
