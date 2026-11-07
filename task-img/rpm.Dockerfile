FROM ghcr.io/1bah/fenrir-base:latest AS fenrir

FROM redhat/ubi9-minimal
LABEL authors="1BAH, Kalinin Iwan <koefic.cien@gmail.com>"


RUN microdnf install -y dnf && microdnf clean all

RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    dnf install -y \
        sudo \
        gnupg2 \
        procps-ng \
        git \
        util-linux \
        rpm-build \
        asciidoctor \
        man-db && \
    dnf clean all

RUN chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo && \
    useradd -G wheel -m -s "/bin/bash" fikus

WORKDIR /home/fikus

COPY --from=fenrir /usr/local/bin/fenrir* /usr/local/bin/
COPY --from=fenrir /usr/local/bin/loki /usr/local/bin/
COPY --from=fenrir --chown=fikus:fikus /etc/fenrir /etc/fenrir
COPY --from=fenrir --chown=fikus:fikus /home/fikus/.fenrir /home/fikus/.fenrir

RUN echo "fikus:breach" | chpasswd && \
    echo "fikus ALL=(ALL) ALL" >> /etc/sudoers

ENTRYPOINT [ "top", "-b" ]
