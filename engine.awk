#!/usr/bin/awk -f

BEGIN {
	# CONSTANTS
	screen_width = 122
	screen_height = 27
	player_x = 1
	player_y = 1

	# Keybinding defaults
	KEY["EXIT"] = "q"
	KEY["UP"] = "z"
	KEY["DOWN"] = "s"
	KEY["LEFT"] = "q"
	KEY["RIGHT"] = "d"
}

# Game settings loader
/^\[GAME\]/ {
	do {
		getline
		split($0,a," = ")
		gamedata[a[1]] = a[2]
	} while (trim($0) != "")
}

/^\[SUBTEXTS\]/ {
	do {
		getline
		line = trim($0)
		if (line != "") {
			subtexts[array_length(subtexts)+1] = line
		}
		
	} while (trim($0) != "")
}

# Game settings loader
/^\[BANNER\]/ {
	y = 0
	do {
		getline
		banner[y] = $0
		y++
	} while (trim($0) != "")

	subtext_nr = randint(1, array_length(subtexts))
	render_banner(banner, subtexts[subtext_nr], screen_width, screen_height)
	system("sleep 2")
	press_key_line = center("PRESS ANY KEY TO START", screen_width)
	print_at_row(press_key_line, 24)
	system("sleep 1")
}

# Keybindings loader
/^\[KEYBINDINGS\]/ {
	do {
		getline
		split($0,a,"=")
		key = trim(a[1])
		value = trim(a[2])
		if (key != "" && value != "") {
			KEY[key] = value
		}
			
	} while (trim($0) != "")
}

# Map loader
/^\[MAP\]$/ {
	map_width = 0
	height = 0
	do {
		EOF = !getline
		if (EOF) {
			exit
		}

		line = trim($0)

		if (map_width == 0) {
			map_width = length(line)
			game_map[height] = line
		} else if (map_width != 0 && length(line) == map_width) {
			game_map[height] = line
		} else {
			print "Game map is jagged, please check " FILENAME " for errors"
		}
		height++
	} while (line != "")
}

END {
	# basic console setup
	printf "\033[?25l" # Hide the cursor
	system("stty -echo")

	

	while(1) {
		handle_input()
		#update()
		clear_screen()
		render()
		system("sleep 1")
	}
	system("reset")
}