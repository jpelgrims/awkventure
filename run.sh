#!/usr/bin/env sh

# Awkventure loading script
#    - Loads all awk files in directory
#    - Reads console size from stty
#    - Loads game file from directory

HEIGHT=$(tput lines)
WIDTH=$(tput cols)

run_game() 
{
    GAMEFILES=$(ls | grep -o '^[a-zA-Z]*.dat$')
    LIBRARIES=$(ls | grep -o '^[a-zA-Z]*.awk$')
    SAVEFILE=$(ls | grep -o '^[a-zA-Z]*.sav$' | head -n 1)

    gawk $(for lib in $LIBRARIES; do echo "-f "; echo $lib; done;) \
        -v screen_width=$WIDTH \
        -v screen_height=$HEIGHT \
        -v TELNET_FLAG=$TELNET \
        -v INTRO_FLAG=$INTRO \
        $(for gamefile in $GAMEFILES; do echo $gamefile; done;) \
        $SAVEFILE
}

if [ "$1" = "TELNET" -o "$2" = "TELNET" ]; then 
    TELNET=1
fi

if [ "$1" = "INTRO" -o "$2" = "INTRO" ]; then 
    INTRO=1
fi

run_game