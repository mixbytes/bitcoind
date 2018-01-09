# Bitcoin Core Dockerfile

![](https://travis-ci.org/mixbytes/bitcoind.svg?branch=master)

## Docker-compose commands

    docker-compose build

    docker-compose up [-d]

    docker-compose down

## Build time variable

Bitcoind release version

    BITCOIN_VER: "0.15.1"

## Run time variables

Username for JSON-RPC connections

    RPCUSER: "user"

Password for JSON-RPC connections

    RPCPASS: "pass"

Allow JSON-RPC connections from specified source. Valid a single IP (e.g. 1.2.3.4), a network/netmask (e.g. 1.2.3.4/255.255.255.0) or a network/CIDR (e.g. 1.2.3.4/24).

    RPCALLOWIP: "127.0.0.1/8"

API's offered over the IPC-RPC interface

    RPCAPI: "admin,db,eth,debug,miner,net,shh,txpool,personal,web3"
