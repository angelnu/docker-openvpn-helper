ARG BASE=alpine
FROM $BASE

ARG arch=none
ENV ARCH=$arch

COPY qemu/qemu-$ARCH-static* /usr/bin/

# iproute2 -> bridge
# bind-tools -> bind
# dhclient -> get dynamic IP
# dnsmasq -> DNS & DHCP server
# coreutils -> need REAL chowm and chmod for dhclient (it uses reference option not supported in busybox)
RUN apk add --no-cache coreutils dnsmasq iproute2 bind-tools dhclient

COPY config /config
COPY bin /usr/local/bin
CMD [ "/usr/local/bin/entry.sh" ]
