ARG S6_ALPINE_IMAGE=s6-alpine:latest
ARG TARGETARCH

FROM ${S6_ALPINE_IMAGE}

COPY aria2-bin/linux/${TARGETARCH}/aria2c /usr/bin/aria2c
RUN chmod +x /usr/bin/aria2c

COPY rootfs /

RUN chmod +x /config-template/script/*.sh && \
    chmod +x /etc/cont-init.d/* && \
    chmod +x /etc/services.d/aria2/* && \
    chmod +x /etc/env-base

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=1 \
    UPDATE_TRACKERS=true \
    CUSTOM_TRACKER_URL= \
    LISTEN_PORT=43318 \
    RPC_PORT=6800 \
    RPC_SECRET= \
    PUID= PGID= \
    DISK_CACHE= \
    IPV6_MODE= \
    UMASK_SET=

EXPOSE 6800 43318 43318/udp

VOLUME /config /downloads