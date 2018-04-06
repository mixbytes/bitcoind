#!/bin/sh

/bin/chmod 700 /data
/bin/chown -R bitcoin /data

COMMAND="-printtoconsole \
	-datadir=/data \
	-server \
	-rpcbind=0.0.0.0 \
	-rpcuser=$RPCUSER \
	-rpcpassword=$RPCPASS \
	-rpcallowip=$RPCALLOWIP"

if [ "$IP4ONLY" == "yes" ];
then
	COMMAND="$COMMAND -onlynet=ipv4"
fi

if [ "$TESTNET" == "yes" ];
then
	COMMAND="$COMMAND -testnet"
fi

echo "command: bitcoind $COMMAND"

exec sudo -H -u bitcoin /usr/local/bin/bitcoind $COMMAND
