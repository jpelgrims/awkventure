#!/usr/bin/env sh

# Awkventure loading script
#    - Loads all awk files in directory
#    - Reads console size from stty
#    - Loads game file from directory

WIDTH=$(stty -a | grep -o 'columns [0-9]*' | cut -d " " -f 2)
HEIGHT=$(stty -a | grep -o 'rows [0-9]*' | cut -d " " -f 2)
GAMEFILE=$(ls | grep -o '^[a-zA-Z]*.dat$')
LIBRARIES=$(ls | grep -o '^[a-zA-Z]*.awk$')

awk $(for lib in $LIBRARIES; do echo "-f "; echo $lib; done;) \
    -v screen_width=$WIDTH \
    -v screen_height=$HEIGHT \
    $GAMEFILE