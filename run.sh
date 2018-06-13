#!/usr/bin/env sh

# Awkventure loading script
#    - Loads all awk files in directory
#    - Reads console size from stty
#    - Loads game file from directory

WIDTH=$(stty -a | grep -o 'columns [0-9]*' | cut -d " " -f 2)
HEIGHT=$(stty -a | grep -o 'rows [0-9]*' | cut -d " " -f 2)
GAMEFILES=$(ls | grep -o '^[a-zA-Z]*.dat$')
LIBRARIES=$(ls | grep -o '^[a-zA-Z]*.awk$')
SAVEFILE = $1

awk $(for lib in $LIBRARIES; do echo "-f "; echo $lib; done;) \
    -v screen_width=$WIDTH \
    -v screen_height=$HEIGHT \
    $(for gamefile in $GAMEFILES; do echo $gamefile; done;) \
    $SAVEFILE
