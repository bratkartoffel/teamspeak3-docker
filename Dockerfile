FROM alpine:3.17

# install packages
RUN apk upgrade --no-cache \
        && apk add --no-cache \
        libstdc++ \
        s6 setpriv

ENV TEAMSPEAK_VERSION=3.13.7 \
	TEAMSPEAK_CHECKSUM=359aac972679cfd98d62af51ddaf80e674cab166e13c6a835e81759097f9ba2e

# install teamspeak3
RUN apk add --no-cache --virtual .fetch-deps ca-certificates tar \
	&& wget "https://files.teamspeak-services.com/releases/server/${TEAMSPEAK_VERSION}/teamspeak3-server_linux_alpine-${TEAMSPEAK_VERSION}.tar.bz2" -O /tmp/server.tar.bz2 \
	&& echo "${TEAMSPEAK_CHECKSUM}  /tmp/server.tar.bz2" | sha256sum -c - \
	&& mkdir -p /opt/ts3server \
	&& tar -xf /tmp/server.tar.bz2 --strip-components=1 -C /opt/ts3server \
	&& rm /tmp/server.tar.bz2 \
	&& apk del .fetch-deps \
	&& mv /opt/ts3server/*.so /opt/ts3server/redist/* /usr/local/lib \
	&& ldconfig /usr/local/lib

# add the custom configurations
COPY rootfs/ /

# setup directory where user data is stored
VOLUME /var/lib/ts3server

#  9987 default voice
# 10011 raw query port
# 10022 ssh query port
# 10080 http query port
# 30033 file transport
EXPOSE 9987/udp 10011 10022 10080 30033

CMD [ "/entrypoint.sh" ]

