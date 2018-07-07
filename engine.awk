#!/usr/bin/gawk -f

#@include "gamelib.awk"
#@include "gamepack"
#@include "stdlib"
#@include "console"

BEGIN {
	# Seed random number generator with day+time
	srand()

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

/^\[ENTITY [a-zA-Z0-9_]+: ART\]/ {
	match($0, /([a-zA-Z0-9_]+):/, groups)
	entity_type = groups[1]
	load_art(entity_type, ENTITY_DATA)
}

/^\[TILES\]/ {
	TILE_DATA[0] = 0
	load_csv(TILE_DATA)
}

/^\[TILE [a-zA-Z0-9_]+: ART\]/ {
	match($0, /([a-zA-Z0-9_]+):/, groups)
	tile_type = groups[1]
	load_art(tile_type, TILE_DATA)
}

/^\[ITEMS\]/ {
	ITEM_DATA[0] = 0
	load_csv(ITEM_DATA)
}



END {

	# Basic console setup
	hide_cursor()
	if (TELNET_FLAG) {
		$FILENAME = "input.txt"
	} else {
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
	#generate_random_walk_cave(WORLD_MAP, world_width, world_height, 3, 3, 1000)
	#ENTITIES[0]["x"] = 5
    #ENTITIES[0]["y"] = 5
	generate_dungeon(WORLD_MAP, world_width, world_height, 30, 6, 10)
	generate_border(WORLD_MAP, world_width, world_height)
	cls()

	if (TELNET_FLAG) {
		multiplayer_loop()
	} else {
		singleplayer_loop()
	}
	

	shutdown()
}

function singleplayer_loop() {
	render(0)
	RUNNING = 1
	while(RUNNING) {

		key = get_input(0)
		handle_input(0, key)
		
		#update()
		render(0)
	}
}

function multiplayer_loop() {
	RUNNING = 1
	while(RUNNING) {
		delete keys

		read_input_file(keys)
		handle_multiplayer_input(keys)
		
		#update()
		render()
	}
}