FROM fedora:43

# Create mask symlinks before D-Bus is installed, we want the connection to the host dbus without conflict
RUN mkdir -p /etc/systemd/system && \
    ln -sf /dev/null /etc/systemd/system/dbus.service && \
    ln -sf /dev/null /etc/systemd/system/dbus.socket && \
    ln -sf /dev/null /etc/systemd/system/dbus-broker.service && \
    dnf install -y --setopt=install_weak_deps=False systemd

# podman does some extra things if create/run is given --systemd=always, or
# if --systemd=true (the default) AND CMD is /usr/sbin/init
# https://docs.podman.io/en/latest/markdown/podman-create.1.html#systemd-true-false-always
CMD ["/usr/sbin/init"]
