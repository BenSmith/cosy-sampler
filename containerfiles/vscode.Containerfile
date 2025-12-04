FROM fedora:43

RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc
RUN echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo
RUN dnf upgrade -y

RUN mkdir -p /etc/systemd/system && \
    ln -sf /dev/null /etc/systemd/system/dbus.service && \
    ln -sf /dev/null /etc/systemd/system/dbus.socket && \
    ln -sf /dev/null /etc/systemd/system/dbus-broker.service && \
    dnf install -y --setopt=install_weak_deps=False \
        bash-completion \
        code \
        curl \
        findutils \
        fira-code-fonts \
        glibc-langpack-en \
        g++ \
        gcc \
        git \
        git-lfs \
        iputils \
        jq \
        less \
        lsb_release \
        make \
        nano \
        node \
        podman \
        podman-compose \
        podman-docker \
        procps-ng \
        psmisc \
        python3 \
        python3-pip \
        strace \
        systemd \
        tar \
        tree \
        unzip \
        wget \
        which \
        xeyes \
        zip \
    && \
    dnf clean all

# cosy create \
#     --image localhost/fedora-vscode \
#     --security-opt label=type:cosy_default_systemd_t \
#     --security-opt no-new-privileges=true \
#     --security-opt seccomp=~/projects/cosy-sampler/seccomp/mcp.json \
#     --volume /home/ben/projects:/home/ben/projects:z \
#     --shm-size=1g \
#     --memory=8g \
#     --memory-swap=8g \
#     --cpus=4 \
#     --pids-limit=4096 \
#     --ulimit nofile=65536:65536 \
#     --ulimit nproc=4096:4096 \
#     --gpu \
#     vscode-dev

CMD ["/usr/sbin/init"]
