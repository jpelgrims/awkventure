#!/usr/bin/env sh
PORT="8888"
if [ $1 ]; then PORT=$1; fi;
while [ 1 ]; do ncat -lkt -p $PORT -e "./run.sh TELNET"; done;