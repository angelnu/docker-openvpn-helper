ARG BASE=alpine
FROM $BASE

ARG arch=none
ENV ARCH=$arch

COPY qemu/qemu-$ARCH-static* /usr/bin/

# iproute2 -> bridge
# bind-tools -> bind
# dhclient -> get dynamic IP
# dnsmasq -> DNS & DHCP server
RUN apk add --no-cache dnsmasq iproute2 bind-tools dhclient

COPY config /config
COPY bin /usr/local/bin
CMD [ "/usr/local/bin/entry.sh" ]
