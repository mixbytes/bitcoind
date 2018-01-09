#!/bin/sh

/bin/chmod 700 /data
/bin/chown -R bitcoin /data

sudo -H -u bitcoin /usr/local/bin/bitcoind \
	-printtoconsole \
	-datadir=/data \
	-server \
	-rpcbind="0.0.0.0" \
	-rpcuser="$RPCUSER" \
	-rpcpassword="$RPCPASS" \
	-rpcallowip="$RPCALLOWIP"

