# [Cosy](https://github.com/BenSmith/cosy) Examples

⚠️ **WARNING: These are reference examples, not production-ready configurations.**

This repository contains example configurations demonstrating how to use various cosy features. These may not suit your security requirements or use cases.

These are not specific to [cosy](https://github.com/BenSmith/cosy), which simply passes through --security-opt to podman.

## ⚠️ Important Disclaimers

**Before using anything here:**
- Understand what it does and why
- Test thoroughly in a non-critical environment
- Adapt to your specific security requirements

**No support provided.** Issues requesting support may be closed without action.

**Not maintained as security policies.** These configurations ~~may~~ will almost certainly become outdated as security standards, kernel versions, and container technologies evolve.

## Who Should Use This?

**✅ You should use these if:**
- You understand container security concepts and need a starting point
- You want to learn by studying working examples
- You plan to review, modify, and test configurations for your needs
- You're comfortable maintaining your own security policies

**❌ You should NOT use these if:**
- You're looking for out-of-the-box security solutions
- You expect ongoing maintenance or security updates
- You're looking for officially supported security policies
- You're not sure if you understand what these configurations do - cosy without these tools still provides decent isolation

## Version Information

These examples were created and tested with:
- **Fedora 43** (host and container base images)
- **Podman 5.x** (rootless)
- **Linux kernel 6.x**

Configurations may need adjustment for other versions or distributions.

## What's Included

### seccomp/
Example seccomp (secure computing mode) profiles demonstrating different security restriction levels. Seccomp filters system calls that containers can make.

### selinux-policies/
Example SELinux policy modules for different cosy use cases. SELinux provides mandatory access control. These require compilation and knowledge of SELinux policy development.

### containerfiles/
Example Containerfile definitions for building container images tailored for specific applications (gaming, multimedia, development, etc.).

## Usage

These are starting points for creating your own configurations. Copy, modify, and test before use.

For the main cosy tool, see: [cosy](https://github.com/BenSmith/cosy)

## Contributing

While contributions are welcome, this is a low-maintenance repository. Pull requests may not be merged, and issues may be closed without action. This is intentional - these are examples, not official configurations.

## License

MIT - same as the main cosy project - see LICENSE file.

---

**Remember:** Security configurations are highly context-dependent. What works for one use case may be inappropriate or insufficient for another. Always understand and test security configurations before deploying them.
