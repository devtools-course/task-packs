FROM ghcr.io/1bah/fenrir-base:latest AS fenrir

FROM ubuntu:latest
LABEL authors="1BAH, Kalinin Iwan <koefic.cien@gmail.com>"

RUN apt update && apt install --no-install-recommends -y \
    sudo \
    gpg \
    git \
    util-linux-extra \
    asciidoctor \
    man-db \
    && apt clean

RUN test -f /usr/bin/man.REAL && mv /usr/bin/man.REAL /usr/bin/man

RUN chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo && \
    useradd -G sudo -m -s "/bin/bash" fikus

WORKDIR /home/fikus

COPY --from=fenrir /usr/local/bin/fenrir* /usr/local/bin/
COPY --from=fenrir /usr/local/bin/loki /usr/local/bin/
COPY --from=fenrir --chown=fikus:fikus /etc/fenrir /etc/fenrir
COPY --from=fenrir --chown=fikus:fikus /home/fikus/.fenrir /home/fikus/.fenrir

RUN echo "fikus:breach" | chpasswd && \
    echo "fikus ALL=(ALL) ALL" >> /etc/sudoers

ENTRYPOINT [ "top", "-b" ]
