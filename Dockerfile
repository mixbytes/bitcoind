FROM alpine:latest AS build
MAINTAINER Mikhail Shubin <mikhail.shubin@gmail.com>

ARG BITCOIN_VER=0.15.1

WORKDIR /build
RUN apk --update upgrade
RUN apk add --virtual build-dependendencies \
wget autoconf automake boost-dev build-base chrpath \
file gnupg libevent-dev libressl libressl-dev \ 
libtool linux-headers protobuf-dev

RUN mkdir /tmp/src
RUN wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz \
-O /tmp/berkley-db.tar.gz
RUN tar -xf /tmp/berkley-db.tar.gz -C /tmp/src
RUN cd /tmp/src/db-4.8.30.NC/build_unix \
  && ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=/build \
  && make install

RUN wget https://github.com/bitcoin/bitcoin/archive/v${BITCOIN_VER}.tar.gz \
-O /tmp/bitcoin.tar.gz
RUN tar -xf /tmp/bitcoin.tar.gz -C /tmp/src
RUN cd /tmp/src/bitcoin-${BITCOIN_VER} \
&& export BDB_PREFIX=/build \
&& ./autogen.sh \
&& ./configure LDFLAGS=-L/build/lib/ CPPFLAGS=-I/build/include/ \
--prefix=/build \
--disable-tests \
--disable-bench \
--disable-man \
--disable-zmq \
--with-gui=no \
--enable-hardening \
&& make install
RUN strip /build/bin/* /build/lib/*.a /build/lib/*.so


FROM alpine:latest

ENV RPCUSER=user
ENV RPCPASS=pass
ENV RPCALLOWIP=192.168.0.1/32
ENV RPCENABLED=no

WORKDIR /data
RUN apk --no-cache --update upgrade \
&& apk add boost boost-program_options libevent libressl sudo
COPY --from=build /build /usr/local
VOLUME [ "/data" ]
EXPOSE 8332 8333
RUN adduser bitcoin -h /data -g 'bitcoin node' -S
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
HEALTHCHECK --interval=2m --timeout=1m \
CMD bitcoin-cli getinfo || exit 1
