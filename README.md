# Awkventure

A roguelike written in *awk*, the text processing tool/language. Development roughly follows along with the 2018 RoguelikeDev tutorial series. 

![Screenshot](https://image.ibb.co/bRLMs8/awk_01.png)

# How to run

In order to run this game you will need a terminal that understands ANSI escape sequences, and gawk. If you're on windows, you can install the Windows Subsystem for Linux and run the game in there.

You can then get the game running locally by running the following commands in your shell:
~~~bash
$ sudo apt install gawk
$ git clone https://github.com/jpelgrims/awkventure.git
$ cd awkventure
$ ./run.sh
~~~

The keyboard controls default to the values listed below. These can be changed in awkventure.dat, under the section named "KEYBINDINGS".

* Move up: Z
* Move down: S
* Move left: Q
* Move right: D
