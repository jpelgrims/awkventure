#!/usr/bin/env sh

# Awkventure loading script
#    - Loads all awk files in directory
#    - Reads console size from stty
#    - Loads game file from directory

WIDTH=80
HEIGHT=24

if [ -z "$0" ]; then 
    TELNET=1
else 
    WIDTH=$(stty -a | grep -o 'columns [0-9]*' | cut -d " " -f 2)
    HEIGHT=$(stty -a | grep -o 'rows [0-9]*' | cut -d " " -f 2)
fi

GAMEFILES=$(ls | grep -o '^[a-zA-Z]*.dat$')
LIBRARIES=$(ls | grep -o '^[a-zA-Z]*.awk$')
SAVEFILE=$(ls | grep -o '^[a-zA-Z]*.awk$' | head -n 1)

gawk $(for lib in $LIBRARIES; do echo "-f "; echo $lib; done;) \
    -v screen_width=$WIDTH \
    -v screen_height=$HEIGHT \
    -v TELNET_FLAG=$TELNET \
    $(for gamefile in $GAMEFILES; do echo $gamefile; done;) \
    $SAVEFILE