#!/usr/bin/gawk -f

BEGIN {
	# Seed random number generator with day+time
	srand()

	world_maps[0] = 0
	scripts[0] = 0
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

/^\[BACKGROUND\]/ {
	load_block(background)
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

	menu_loop()
	shutdown()
}

function shutdown() {
	cls()
	printf "\033[H"
	printf "\033[?25h"
	if (!TELNET_FLAG) {
		system("stty echo")
	}
	exit 0
}

function singleplayer_loop() {
	POINTER_X = middle_viewport_x
	POINTER_Y = middle_viewport_y
	world_height = viewport_height
	world_width = viewport_width

	if (!savefile()) {
		add_entity("player", player_x, player_y)
		generate_level(world_width, world_height)
		play_intro()
	}

	cls()
	
	add_message("Welcome to awkventure!")
	render(0)
	RUNNING = 1
	while(RUNNING) {

		key = get_input(0)
		take_turn = handle_input(0, key)
		
		if (take_turn) {
			update_entities()
		}
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