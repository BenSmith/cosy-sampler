# Containerfiles (Dockerfiles, but podman)

These Containerfiles demonstrate how to build container images for specific use cases with cosy. They were created for testing and personal use.

## ⚠️ Important Disclaimers

- **Not maintained** - Base images, package versions, and dependencies change
- **May have security issues** - No security audits, may include outdated packages
- **Personal configurations** - Reflect maintainer's preferences, not best practices
- **Test before use** - Always review, modify, and test before using
- **No support provided** - These are examples, not images for critical environments

## Sample Containerfiles

### Systemd (systemd.Containerfile)

Minimal Fedora image with systemd for applications requiring init system.

**Includes:**
- systemd
- Basic services configured
- Unnecessary services masked

**Use with:** `cosy create --image localhost/fedora-systemd ...`

---

### VS Code (vscode.Containerfile)

Development environment with VS Code and common development tools.

**Includes:**
- Visual Studio Code
- Common development tools (git, compilers)
- Podman for Dev Containers support (use with `cosy create --podman`)

**Use with:** `cosy create --podman -v ~/Projects:/home/$USER/Projects:Z --image localhost/fedora-vscode:43 ...`

---

## Building Images

```bash
# Build an image
podman build -t localhost/fedora-vscode:43 -f vscode.Containerfile .

# Use with cosy
cosy create --gpu --podman --image localhost/fedora-vscode:latest dev-machine
```

## Disclaimer

These Containerfiles are **examples only**. They:
- May install outdated or vulnerable packages
- Reflect personal preferences, not security best practices
- Require review and modification for your use case
- Are not maintained for correctness or security

**Create and maintain your own Containerfiles based on your requirements and security policies.**
