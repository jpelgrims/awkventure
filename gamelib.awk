# Game functions library
# Requires stdlib.awk

function add_entity(type, pos_x, pos_y) {
	if (id != 0) {
		id = array_length(entities) + 1
	} else {
		id = 0
	}
	
	entities[id, "type"] = type
	entities[id, "x"] = pos_x
	entities[id, "y"] = pos_y
	nr_of_entities++
}

function print_at_row(line, row) {
	printf "\033[%s;0H", row
	printf line
}

# Add fading
function render_banner(banner_lines, subtext, screen_width, screen_height) {
	system("clear")

	banner_height = array_length(banner_lines)
	space_left = screen_height-(banner_height)
	space = int(space_left/2)
	for (y=0;y<=space;y++) {
		printf "\n"
	}
	for (y=0;y<=banner_height;y++) {
		center(banner_lines[y], screen_width)
	}
	printf "\n"
	center(subtext, screen_width)
	for (y=0;y<=space;y++) {
		printf "\n"
	}
}

function get_input(   input) {
	system("stty -echo") # turn off echo
	cmd = "bash -c 'read -n 1 input; echo $input'"
	cmd | getline input
	close(cmd)
	return input
}

function is_blocked(x, y) {
	char = WORLD_MAP[x, y]
	return TILE_DATA[char, "blocked"] == "true"
}

function activate_tile(activator_id, x, y) {

}

function use_item(user_id, item) {

}

function handle_input(   key) {
	key = get_input()

	if (length(key) != 0) {
		x = entities[0, "x"]
		y = entities[0, "y"]
		if (key == KEY["UP"]) { y-- }  
		else if (key == KEY["DOWN"]) { y++ } 
		else if (key == KEY["LEFT"]) { x-- } 
		else if (key == KEY["RIGHT"]) { x++} 
		else if (key == KEY["QUIT"]) {
			cls()
			printf "\033[H"
			printf "\033[?25h"
			system("stty echo")
			exit 0
		}
		if (is_blocked(x, y) == 0) {
			entities[0, "x"] = x
			entities[0, "y"] = y
		}
	}



}

function update_screen_buffer() {
	# Render world
	for (y=0; y<=world_height;y++) {
		for (x=0;x<=world_width;x++) {
			SCREEN_BUFFER[x, y]=WORLD_MAP[x, y]
		}
	}

	for (i=0; i<=nr_of_entities;i++) {
		type = entities[i, "type"]
		x = entities[i, "x"]
		y = entities[i, "y"]
		char = ENTITY_DATA[type, "char"]
		SCREEN_BUFFER[x, y] = char
	}
}

function camera_view() {

}

# Line-based buffer
function render_screen_buffer() {
	printf "\033[H" 
	for (y=0; y<screen_height;y++) {
		for (x=0;x<screen_width;x++) {
			if (CURRENT_SCREEN[x, y] != SCREEN_BUFFER[x, y]) { # only print if screen line changed
				printf "\033[%s;%sH%c", y+1, x, SCREEN_BUFFER[x, y]
				CURRENT_SCREEN[x, y] = SCREEN_BUFFER[x, y]
			}
		}
	}
}

function update() {

}

function set_level(level_nr) {

	# Load level map
	world_height = world_maps[level_nr, "map_height"]
	world_width = world_maps[level_nr, "map_width"]
	delete WORLD_MAP

	for (y=0; y<=world_height;y++) {
		for (x=0;x<=world_width;x++) {
			WORLD_MAP[x, y]=world_maps[level_nr, x, y]
		}
	}

	# Set level enter flag
	LEVEL_ENTER = 1
}

function run_script() {
	for (i in SCRIPT) {
		script_line = SCRIPT[i]
		if (match(script_line, /^ON level_enter/)) {
			# ...
		}
	}
}