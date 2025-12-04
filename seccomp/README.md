# Seccomp Profiles

⚠️ **Example seccomp profiles - not security configurations for critical environments**

These seccomp (secure computing mode) profiles demonstrate different levels of system call restrictions for containers. They were created for testing cosy's seccomp integration and personal use.

## ⚠️ Important Disclaimers

- **Not security audited** - These have not been reviewed by security experts
- **May be outdated** - Kernel versions, syscalls, and security requirements change
- **Context-dependent** - What's appropriate for one workload may be wrong for another
- **Test thoroughly** - Always test profiles with your specific applications before use in a critical environment
- **No maintenance promise** - These may not be updated for new kernel versions or security findings

**Create and maintain your own seccomp profiles based on your threat model and application requirements.**

## Profiles

### `moderate.json`

Blocks syscalls that typical GUI applications don't need:

**Blocked syscalls:**
- **Debugging/tracing**: `ptrace`, `process_vm_readv`, `process_vm_writev`
- **Performance monitoring**: `perf_event_open`
- **ASLR disabling**: Blocks `personality()` calls that disable ASLR (enforces memory randomization)
- **Kernel operations**: `bpf`, `userfaultfd`, `add_key`, `keyctl`, `request_key`
- **Time manipulation**: `clock_settime`, `clock_adjtime`, `settimeofday`, `adjtimex`
- **Namespace operations**: `setns`, `unshare`
- **System operations**: `reboot`, `swapon`, `swapoff`, `mount`, `umount2`, `pivot_root`
- **Advanced I/O**: `io_uring_setup`, `io_uring_enter`, `io_uring_register`
- **Memory operations**: `mbind`, `set_mempolicy`, `migrate_pages`, `move_pages`
- **Module operations**: `init_module`, `finit_module`, `delete_module`

**Use cases:**
- General GUI applications (browsers, editors, media players)
- Games and graphics applications
- Audio/video production tools
- Development environments (except kernel debugging)

**Compatibility:**
- ✅ Works with most GUI apps
- ✅ Compatible with GPU acceleration (`--gpu`)
- ✅ Compatible with audio (`--audio`)
- ✅ High-level language debuggers (Python pdb, Node.js) work fine
- ⚠️ Blocks native debuggers (gdb, lldb) - use debug profile for C/C++/Rust debugging
- ⚠️ Enforces ASLR (cannot be disabled)
- ⚠️ May break profilers - use debug profile for profiling
- ⚠️ Some high-performance apps using io_uring may need podman's default (no custom seccomp)

### `debug.json` - Development-friendly with debugging support

Similar security to moderate profile, but allows native debugging and profiling:

**Allowed (in addition to moderate):**
- **Debugging**: `ptrace`, `process_vm_readv`, `process_vm_writev`
- **Profiling**: `perf_event_open`
- **ASLR control**: Can disable ASLR via `personality()` for consistent debugging

**Still blocked (same as moderate):**
- **Kernel operations**: `bpf`, `userfaultfd`, keyring operations
- **Time manipulation**: `clock_settime`, etc.
- **Namespace operations**: `setns`, `unshare`
- **System operations**: `reboot`, `mount`, `umount2`, etc.
- **Advanced I/O**: `io_uring`
- **Module operations**: `init_module`, etc.

**Use cases:**
- C/C++/Rust development with gdb/lldb
- Performance profiling and optimization
- Systems programming and debugging
- Learning low-level programming

**Compatibility:**
- ✅ All GUI applications
- ✅ Native debuggers (gdb, lldb, strace)
- ✅ Performance profilers (perf, valgrind)
- ✅ Can disable ASLR for debugging
- ✅ Compatible with all cosy features
- ⚠️ Still blocks kernel-level debugging and eBPF

### `mcp.json` - For unvetted MCP development tools

Identical security to moderate profile, but optimized for the MCP tool threat model:

**Threat model:**
- **Primary concern**: Prompt injection causing data exfiltration
- **Secondary concern**: Malicious code in unvetted MCP tools
- **Cosy already provides**: Isolated home, network namespace, no host filesystem access

**Seccomp additions:**
- Same syscall restrictions as moderate profile
- Blocks kernel-level attacks and privilege escalation
- Enforces ASLR
- Blocks debugging/tracing that could inspect other processes

**Why this profile:**
- MCP tools (Node.js/Python) don't need native debugging syscalls
- Network access is needed (for LLM APIs) but isolated by cosy's network namespace
- File access is needed but limited to isolated container home
- Additional kernel-level protection against malicious tool code

**Defense-in-depth strategy:**
1. **Cosy isolation**: Separate home, network namespace, no host mounts
2. **Seccomp**: Block kernel attacks, privilege escalation, debugging
3. **Least privilege**: Only mount data you want the MCP tool to access

**Use cases:**
- Running MCP servers from npm/pip you haven't audited
- Testing new MCP tools before trusting them
- Sandboxed AI agent development
- Running LLM-connected tools with prompt injection concerns

**Compatibility:**
- ✅ Node.js/Python MCP tools
- ✅ Network access to LLM APIs
- ✅ File I/O within container
- ✅ All standard MCP operations
- ⚠️ No ptrace/debugging (use debug profile if needed)

### `strict.json` - Heavy hardening for untrusted applications

Additional restrictions beyond moderate profile:

**Additionally blocked:**
- **Advanced memory**: `remap_file_pages`, `memfd_secret`
- **Notification**: `fanotify_init`, `fanotify_mark`
- **Chroot operations**: `chroot` (containers shouldn't need this)

**Use cases:**
- Running untrusted applications
- Sandboxing unknown software
- Heavy isolation scenarios

**Compatibility:**
- ✅ Basic GUI applications
- ✅ Simple games and media players
- ⚠️ May break complex applications
- ⚠️ May break containerized development tools (Docker-in-Docker, etc.)
- ❌ Not compatible with systemd containers (removes chroot)

## Usage

### With cosy

Use the `--security-opt` flag to apply a profile:

```bash
# Moderate profile (recommended for most apps)
cosy create --security-opt seccomp=/path/to/cosy/seccomp/moderate.json myapp

# Debug profile (for development with gdb/lldb)
cosy create --security-opt seccomp=/path/to/cosy/seccomp/debug.json devbox

# MCP profile (for unvetted MCP tools)
cosy create --security-opt seccomp=/path/to/cosy/seccomp/mcp.json mcp-server

# Strict profile (for untrusted apps)
cosy create --security-opt seccomp=/path/to/cosy/seccomp/strict.json untrusted-app

# From current directory
cosy create --security-opt seccomp=$(pwd)/seccomp/moderate.json myapp
```

### Testing a profile

Before committing to a profile, test with dry-run:

```bash
# Test if the profile works
cosy run --dry-run --security-opt seccomp=seccomp/moderate.json myapp -- /bin/true

# Run with the profile
cosy run --security-opt seccomp=seccomp/moderate.json myapp firefox
```

### When to use each profile

**Default (podman's seccomp):**
- When you need maximum compatibility
- Containers that need kernel-level debugging or eBPF
- When you trust the application completely

**Moderate:**
- General purpose GUI applications
- Applications from third-party repositories
- When you want defense-in-depth without breaking functionality
- Best balance of security and compatibility

**Debug:**
- C/C++/Rust development containers
- When you need to use gdb, lldb, or strace
- Performance profiling with perf or valgrind
- Learning systems programming
- Similar security to moderate, but allows native debugging

**MCP:**
- Running unvetted MCP servers from npm/pip
- Testing new LLM-connected tools
- AI agent development with prompt injection concerns
- When you need network access but want syscall-level protection
- Same security as moderate, but threat model focused on MCP tools

**Strict:**
- Untrusted binaries from unknown sources
- Running potentially malicious code in isolation
- Maximum security scenarios
- When you've verified the app works with this profile
- Sacrifice some compatibility for maximum hardening

## What's NOT blocked

All profiles still allow:
- All standard POSIX operations (file I/O, networking, process management)
- Graphics/GPU operations
- Audio operations
- IPC (pipes, sockets, shared memory)
- Threading and synchronization
- Time reading (but not setting)
- Resource limits
- Signal handling
- Basic namespace features needed by containers

## Troubleshooting

### Application won't start

Try profiles in order of decreasing restrictions:
1. No custom seccomp (podman's default)
2. Debug profile (allows debugging/profiling)
3. Moderate or MCP profile (good security balance)
4. Strict profile (maximum restrictions)

### Finding which syscall is blocked

Use `podman logs` to see if seccomp is blocking calls:

```bash
# Run with the profile
cosy run --security-opt seccomp=seccomp/moderate.json myapp mycommand

# Check for seccomp violations
podman logs <container-id> 2>&1 | grep -i seccomp
```

You can also use `strace` in a container without seccomp to see what syscalls an app uses:

```bash
# Run without seccomp to trace
cosy run --security-opt seccomp=unconfined myapp -- strace -c mycommand
```

## Creating Your Own Profiles

These profiles are starting points, not final solutions. To create your own:

1. Start with Docker/Podman's default seccomp profile
2. Identify syscalls your application needs (use `strace`)
3. Block unnecessary syscalls based on your threat model
4. Test extensively in your environment
5. Document your decisions and assumptions

All profiles here are based on podman's default profile with specific syscalls removed. You can:
- Start with one of these profiles
- Add or remove syscalls from the `"names"` array in the first syscall rule
- Test thoroughly with your applications

**Resources:**
- [Podman seccomp documentation](https://docs.podman.io/en/latest/markdown/podman-run.1.html#security-opt-option)
- [Seccomp profile format](https://github.com/opencontainers/runtime-spec/blob/main/config-linux.md#seccomp)
- [Linux syscalls reference](https://man7.org/linux/man-pages/man2/syscalls.2.html)
- [Docker seccomp documentation](https://docs.docker.com/engine/security/seccomp/)

## Security Notes

- **Defense in depth**: Seccomp is one layer. Combine with capabilities, SELinux, and user namespaces
- **Not foolproof**: A determined attacker with access to allowed syscalls can still cause damage
- **Application compatibility**: More restrictive profiles may break applications in unexpected ways
- **Systemd containers**: The strict profile removes `chroot` which systemd may need. Use moderate, debug, or MCP profiles for systemd containers.

## Disclaimer

These profiles are **examples only**. They represent configurations used for testing and personal development, not security recommendations. Your security requirements are different from mine.

**Create and maintain your own seccomp profiles based on your threat model and application requirements.**
