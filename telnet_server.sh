#!/usr/bin/env sh
PORT="8888"
if [ $1 ]; then PORT=$1; fi;
#bash -c "./run.sh TELNET"
while [ 1 ]; do ncat -lkt -p $PORT -e "./telnet_client.sh"; done;