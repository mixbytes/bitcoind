FROM alpine:latest AS build
MAINTAINER Mikhail Shubin <mikhail.shubin@gmail.com>

ENV BERKELEYDB_VER=db-4.8.30.NC
ENV BERKELEYDB_PREFIX=/opt/${BERKELEYDB_VER}
ENV BITCOIN_VER=0.15.1

WORKDIR /build

RUN apk --update upgrade
RUN apk add --virtual build-dependendencies \
wget autoconf automake boost-dev build-base chrpath \
file gnupg libevent-dev libressl libressl-dev \ 
libtool linux-headers protobuf-dev miniupnpc-dev

RUN wget https://github.com/bitcoin/bitcoin/archive/v${BITCOIN_VER}.tar.gz -O /tmp/bitcoin.tar.gz
RUN tar -xf /tmp/bitcoin.tar.gz -C /build
RUN cd bitcoin-${BITCOIN_VER} \
&& ./autogen.sh \
&& ./configure LDFLAGS=-L${BERKELEYDB_PREFIX}/lib/ CPPFLAGS=-I${BERKELEYDB_PREFIX}/include/ \
--prefix=/build \
--disable-wallet \
#--enable-upnp-default \ ?
--disable-tests \
--disable-bench \
# ???
#--disable-ccache \
--disable-man \
--disable-zmq \
--with-gui=no \
--with-miniupnpc \
&& make \
&& make install

RUN strip /build/bin/*
RUN strip /build/lib/*.a
RUN strip /build/lib/*.so

#second stage
FROM alpine:latest
WORKDIR /bitcoin

RUN adduser bitcoin -h /bitcoin -g 'bitcoin node' -S

RUN apk --no-cache --update upgrade \
&& apk add boost boost-program_options \
libevent libressl miniupnpc

COPY --from=build /build/bin /usr/local/bin
COPY --from=build /build/lib /usr/local/lib

VOLUME ["/bitcoin"]

#EXPOSE 8332 8333 18332 18333
EXPOSE 8333

ENTRYPOINT ["/usr/local/bin/bitcoind", "-printtoconsole"]

#ENTRYPOINT ["/bin/sh"]

HEALTHCHECK --interval=2m --timeout=1m \
CMD bitcoin-cli getinfo || exit 1
