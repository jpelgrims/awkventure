#!/usr/bin/gawk -f

#@include "gamelib.awk"
#@include "gamepack"
#@include "stdlib"
#@include "console"

BEGIN {
	# Seed random number generator with day+time
	srand()

	# CONSTANTS & GLOBALS
	viewport_height = screen_height-2
	viewport_width = screen_width-20

	# Player position
	player_x = 2
	player_y = 2

	world_maps[0] = 0
	scripts[0] = 0

	# Worldmap
	WORLD_MAP[0] = 0
	world_width = 0
	world_height = 0
	level = 0


	# Entities
	ENTITIES["length"] = 0
	add_entity("player", player_x, player_y)
}

/^\[GAME\]/ {
	load_ini(gamedata)
}

/^\[SUBTEXTS\]/ {
	load_block(subtexts)
}

/^\[BANNER\]/ {
	load_block(banner)
}

/^\[STORY\]/ {
	load_block(story)
}

/^\[CREDITS\]/ {
	load_block(credits)
}

/^\[KEYBINDINGS\]/ {
	load_ini(KEY)
}

/^\[LEVEL [0-9]+: MAP\]/ {
	match($0, /([0-9]+)/)
	level_nr = substr($0, RSTART, RLENGTH)
	load_map(level_nr)
}

/^\[LEVEL [0-9]+: SCRIPT\]/ {
	match($0, /([0-9]+)/, groups)
	level_nr = groups[1]

	script = load_script()
	scripts["level"][level_nr] = script
}

/^\[ENTITIES\]/ {
	ENTITY_DATA[0] = 0
	load_csv(ENTITY_DATA)
}

/^\[TILES\]/ {
	TILE_DATA[0] = 0
	load_csv(TILE_DATA)
}

/^\[ITEMS\]/ {
	ITEM_DATA[0] = 0
	load_csv(ITEM_DATA)
}



END {

	# Basic console setup
	hide_cursor()
	if (!TELNET_FLAG) {
		system("stty -echo")
	}
	cls()

	if (INTRO_FLAG) {
		# Show game title
		subtext_nr = randint(0, array_length(subtexts))
		
		for(i=0;i<=200;i+=5) {
			
			set_foreground_color(i, 0, 0)
			for(y=0;y<length(banner);y++) {
				move_cursor(0, (screen_height-12)/2+y)
				center(banner[y], screen_width)
			}
			sleep(0.05)
		}
		
		sleep(2)
		cls()

		# Show game story
		for (i in story) {
			move_cursor(4, (screen_height-8)/2+i)
			split(story[i], words," ")
			for (w in words) {

				for (o=1;o<=length(words[w]);o++) {
					char = substr(words[w], o, 1)
					if (char != ".") {
						fade_in(char)
						sleep(0.03)
					} else {
						printf char
						sleep(1.5)
					}
					
				}
				sleep(0.05)
				printf " "
			}
			
		}
		show_cursor()
		printf "\n\n   Press any key to start"
		get_input()
		hide_cursor()

	}

	set_level(1)
	world_height = viewport_height
	world_width = viewport_width
	delete WORLD_MAP
	generate_dungeon(WORLD_MAP, world_width, world_height, 30, 6, 10)
	cls()
	render()


	while(1) {

		key = get_input(0)
		handle_input(key)
		#update()
		render()
		sleep(0.01)
	}
	system("reset")
}