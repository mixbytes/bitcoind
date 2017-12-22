#!/bin/sh

/bin/chmod 700 /data
/bin/chown -R bitcoin /data

if [[ $RPCENABLED == "yes" ]] || [[ $RPCENABLED == "Yes" ]] || [[ $RPCENABLED == "YES" ]] || [[ $RPCENABLED == "Y" ]];
	then
		sudo -H -u bitcoin /usr/local/bin/bitcoind \
		-printtoconsole \
		-datadir=/data \
		-server \
		-rpcuser="$RPCUSER" \
		-rpcpassword="$RPCPASS" \
		-rpcallowip="$RPCALLOWIP"
	else
		sudo -H -u bitcoin /usr/local/bin/bitcoind \
		-printtoconsole \
		-datadir=/data
fi
