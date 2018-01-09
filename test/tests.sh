#!/bin/sh
set -ex
sudo docker build -t bitcoind:testing .
sudo curl -fsSL https://goss.rocks/install | sh
sudo GOSS_SLEEP=5 dgoss run -e RPCAPI="admin,db,eth,debug,miner,net,shh,txpool,personal,web3" -e RPCALLOWIP="0.0.0.0/0" -e RPCUSER=user -e RPCPASS=pass -p 8332:8332 -p 8333:8333 bitcoind:testing
sudo docker run -d -p 8332:8332 -p 8333:8333 -e RPCALLOWIP="0.0.0.0/0" -e RPCUSER=user -e RPCPASS=pass bitcoind:testing
sleep 60
curl --user user:pass --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "getblockchaininfo", "params": [] }' -H 'content-type: text/plain;' http://127.0.0.1:8332

