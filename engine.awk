#!/usr/bin/gawk -f

#@include "gamelib.awk"
#@include "gamepack"
#@include "stdlib"
#@include "console"

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

	if (INTRO_FLAG) {
		play_intro()
	}

	menu_loop()
	shutdown()
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

function play_intro() {
	# Show game title
	subtext_nr = randint(0, array_length(subtexts))
	
	draw_banner()
	
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

function draw_banner() {
	for(y=0;y<length(banner);y++) {
		move_cursor(0, (screen_height-12)/2+y)
		center(banner[y], screen_width)
	}
}

function draw_background() {
	for(y=0;y<length(background);y++){
		print(background[y])
	}
}

function draw_banner_faded() {
	for(i=0;i<=200;i+=5) {
		set_foreground_color(i, 0, 0)
		draw_banner()
		sleep(0.05)
	}
}

function menu_loop() {
	draw_banner_faded()
	cursor_pos = 1
	nr_of_menu_items = 2
	sleep(1)
	set_foreground_color(255, 255, 255)
	draw_background()
	while (1) {

		if (savefile()) {
			putch("Continue game", 35, 17)
		} else {
			putch("New game", 35, 17)
		}
		putch("Exit", 35, 18)
		
		putch("Press (E) to choose", 35, 20)
		putch("Made by Jelle Pelgrims", 59, 23)

		for(y=16;y<17+nr_of_menu_items;y++) {
			putch(" ", 33, y+cursor_pos-1)
		}

		putch(">", 33, 17+cursor_pos-1)

		key = get_input(0)

		if (key == KEY["UP"] || match(key, /\033\[A/)) {
			if (cursor_pos > 1) {
				cursor_pos-- 
			}
		} else if (key == KEY["DOWN"] || match(key, /\033\[B/)) {
			if (cursor_pos < nr_of_menu_items) {
				cursor_pos++ 
			}
		} else if (match(key,  /e|E/)) {
			if (cursor_pos == 1) {
				singleplayer_loop()
			} else if (cursor_pos == 2) {
				shutdown()
			}
		}  else if (match(key,  /^\033$/)) {
			shutdown()
		}
		sleep(0.01)
	}
}