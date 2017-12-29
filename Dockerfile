FROM alpine:latest AS build
MAINTAINER Mikhail Shubin <mikhail.shubin@gmail.com>

# Bitcoin Core version (0.12.1+)
ARG BITCOIN_VER="0.15.1"
ENV BDB_MD5="a14a5486d6b4891d2434039a0ed4c5b7  /tmp/berkley-db.tar.gz"

WORKDIR /build
RUN apk --update add --virtual build-dependendencies \
wget gnupg autoconf automake boost-dev build-base chrpath \
file libevent-dev libressl libressl-dev \
libtool linux-headers protobuf-dev

RUN mkdir /tmp/src
RUN wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz \
-O /tmp/berkley-db.tar.gz
RUN echo "${BDB_MD5}" | md5sum -c -
RUN tar -xf /tmp/berkley-db.tar.gz -C /tmp/src
RUN cd /tmp/src/db-4.8.30.NC/build_unix \
  && ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=/build \
  && make install

RUN wget -O- https://bitcoin.org/laanwj-releases.asc | gpg --import
RUN wget https://bitcoin.org/bin/bitcoin-core-${BITCOIN_VER}/SHA256SUMS.asc \
-O /tmp/SHA256SUMS.asc
RUN wget https://bitcoin.org/bin/bitcoin-core-${BITCOIN_VER}/bitcoin-${BITCOIN_VER}.tar.gz \
-O /tmp/bitcoin-${BITCOIN_VER}.tar.gz
RUN gpg --verify /tmp/SHA256SUMS.asc
RUN cd /tmp && grep "bitcoin-${BITCOIN_VER}.tar.gz\$" /tmp/SHA256SUMS.asc | sha256sum -c - 
RUN tar -xf /tmp/bitcoin-${BITCOIN_VER}.tar.gz -C /tmp/src
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

ENV RPCUSER="user"
ENV RPCPASS="pass"
ENV RPCALLOWIP="127.0.0.1/8"

WORKDIR /data
RUN apk --no-cache --update upgrade \
&& apk --no-cache add boost boost-program_options libevent libressl sudo
COPY --from=build /build /usr/local
VOLUME [ "/data" ]
EXPOSE 8332 8333
RUN adduser bitcoin -h /data -g 'bitcoin node' -S
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
HEALTHCHECK --interval=1m --timeout=30s \
CMD bitcoin-cli -rpcuser=$RPCUSER -rpcpassword=$RPCPASS getblockchaininfo || exit 1
