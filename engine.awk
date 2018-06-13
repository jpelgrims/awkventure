#!/usr/bin/awk -f

# Awkventure game engine
# Requires gamelib.awk

BEGIN {

	# CONSTANTS & GLOBALS

	# Player position
	player_x = 2
	player_y = 2

	world_maps[0] = 0 

	# Worldmap
	WORLD_MAP[0] = 0
	world_width = 0
	world_height = 0
	level = 0


	# Entities
	entities[0] = 0
	nr_of_entities = 0

	add_entity("player", player_x, player_y)

	# Screen
	CURRENT_SCREEN[0] = 0
	SCREEN_BUFFER[0] = 0



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
	match($0, /([0-9]+)/)
	level_nr = substr($0, RSTART, RLENGTH)

	load_block(script)

	for(i in script) {
		world_maps[level_nr, "script", settings[i]] = script[i]
	}
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

	# Show game title
	subtext_nr = randint(1, array_length(subtexts))
	render_banner(banner, subtexts[subtext_nr], screen_width, screen_height)
	system("sleep 2")
	cls()

	# Show game story
	for (i in story) {
		story_line = center(story[i], screen_width)
		print_at_row(story_line, 12+i)
		system("sleep 2")
	}
	system("sleep 5")

	# Press key to start message
	press_key_line = center("PRESS ANY KEY TO START", screen_width)
	print_at_row(press_key_line, 24)
	system("sleep 1")

	# Basic console setup
	printf "\033[?25l" # Hide the cursor
	system("stty -echo")
	cls()

	set_level(1)

	while(1) {
		handle_input()
		#update()

		update_screen_buffer()
		render_screen_buffer()

		system("sleep 0.01")
	}
	system("reset")
}