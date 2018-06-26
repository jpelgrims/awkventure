#!/usr/bin/env sh

# Awkventure loading script
#    - Loads all awk files in directory
#    - Reads console size from stty
#    - Loads game file from directory

WIDTH=80
HEIGHT=24

if [ "$1" = "INTRO" -o "$2" = "INTRO" ]; then 
    INTRO=1
fi

if [ "$1" = "TELNET" -o "$2" = "TELNET" ]; then 
    TELNET=1
    echo "+--------------------------+"
    echo "| Awkventure telnet server |"
    echo "+--------------------------+"
    echo ""
    echo "Your game will begin shortly."
    read temp
    # Set telnet char mode, i.e. client will only read one character before sending to server
    echo "\377\375\042\377\373\001"
    # Find console size 
    echo "\033[s\033[999;999H\033[6n\033[u"
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
    -v INTRO_FLAG=$INTRO \
    $(for gamefile in $GAMEFILES; do echo $gamefile; done;) \
    $SAVEFILE