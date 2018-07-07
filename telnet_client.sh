#!/usr/bin/env bash

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
    read -n 1 command

    if echo $command | grep -Eq '^[Pp|Play|play]'; then
        echo "Playing as guest..."
        echo $'\377\375\042\377\373\001'
        bash -c "./run.sh"
    elif echo $command | grep -Eq '^[Cc|Change|change]'; then
        echo "Functionality not implemented yet."
        sleep 1
        menu
    elif echo $command | grep -Eq '^[Rr|Register|register]'; then
        echo "Functionality not implemented yet."
        sleep 1
        menu
    elif echo $command | grep -Eq '^[Ll|Login|login]'; then
        echo "Functionality not implemented yet."
        sleep 1
        menu
    elif echo $command | grep -Eq '^([Ee]|\033)'; then
        echo "Goodbye"
        exit 0
    else
        menu
    fi
}

multiplayer() 
{
    # Get client ID
    USER_ID="${NCAT_REMOTE_ADDR}_${NCAT_REMOTE_PORT}"
    INPUT_FILE="input.txt"
    SCREEN_FILE="${USER_ID}.txt"

    # Set telnet char mode
    echo $'\377\375\042\377\373\001'

    while true; do
        if read -n 1 -t 0.01 char; then
            echo "${USER_ID} ${char}" >> $INPUT_FILE
        fi 
        if [ -f $SCREEN_FILE ]; then
            printf "\033[2J"
            cat $SCREEN_FILE
        fi
        sleep 0.01
    done
}

menu