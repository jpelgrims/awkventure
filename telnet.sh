#!/usr/bin/env sh
PORT="8888"
if [ -z "$0" ]; then PORT=$0; fi;
while [ 1 ]; do ncat -lkt -p $PORT -e ./run.sh; done;