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
    SAVEFILE=$(ls | grep -o '^[a-zA-Z]*.awk$' | head -n 1)

    gawk $(for lib in $LIBRARIES; do echo "-f "; echo $lib; done;) \
        -v screen_width=$WIDTH \
        -v screen_height=$HEIGHT \
        -v TELNET_FLAG=$TELNET \
        -v INTRO_FLAG=$INTRO \
        $(for gamefile in $GAMEFILES; do echo $gamefile; done;) \
        $SAVEFILE
}

menu()
{
    printf "\033[2J"
    echo "+--------------------------+"
    echo "| Awkventure telnet server |"
    echo "+--------------------------+"
    echo ""
    echo "   P)lay as guest"
    echo "   C)hange controls"
    echo "   R)egister"
    echo "   L)ogin"
    echo "   E)xit"
    echo ""
    read -p "Command > " command

    case "$command" in 
    *[Pp]*)
        echo "Playing as guest..."
        ;;
    *[Cc]*)
        echo "Functionality not implemented yet."
        sleep 1
        menu
        ;;
    *[Rr]*)
        echo "Functionality not implemented yet."
        sleep 1
        menu
        ;;
    *[Ll]*)
        echo "Functionality not implemented yet."
        sleep 1
        menu
        ;;
    *[Ee]*)
    echo "Goodbye"
        exit 0
        ;;
    *)
        menu
        ;;
    esac
}



if [ "$1" = "INTRO" -o "$2" = "INTRO" ]; then 
    INTRO=1
fi

if [ "$1" = "TELNET" -o "$2" = "TELNET" ]; then 
    TELNET=1
    menu

    # Set telnet char mode, i.e. client will only read one character before sending to server
    echo "\377\375\042\377\373\001"
fi

run_game