BEGIN {
	POINTER_X = 0
	POINTER_Y = 0

	CURRENT_MENU = "legend"

	viewport_height = screen_height
	viewport_width = screen_width-20

	middle_viewport_x = int(viewport_width/2)
	middle_viewport_y = int(viewport_height/2)
}

function ray_cast(type, direction, origin_x, origin_y,   delta_x, delta_y, distance) {
	distance = 0

	delta_x = 0
	delta_y = 0

	if (direction == "UP") {
		delta_y = -1
	} else if (direction == "DOWN") {
		delta_y = 1
	} else if (direction == "LEFT") {
		delta_x = -1
	} else if (direction == "RIGHT") {
		delta_x = 1
	}

	while (distance<10) {
		x = origin_x+delta_x*(distance+1)
		y = origin_y+delta_y*(distance+1)
		if (is_blocked(x, y, "tile") || is_corridor(x, y)) {
			return distance
		} else {
			distance += 1
		}	
	}
	return distance
}

function calculate_room_LOS(   x, y) {
    delete VISIBLE_MAP

	player_x = ENTITIES[0]["x"]
	player_y = ENTITIES[0]["y"]

	get_room_dimensions(player_x, player_y, room)

	for(x=room["x"]-1;x<=room["x"]+room["width"];x++) {
		for(y=room["y"]-1;y<=room["y"]+room["height"];y++) {
			if(!is_blocked(x, y, "tile")) {
				VISIBLE_MAP[x][y] = 1
				VISIBLE_MAP[x][y-1] = 1
				VISIBLE_MAP[x][y+1] = 1
				VISIBLE_MAP[x-1][y] = 1
				VISIBLE_MAP[x-1][y-1] = 1
				VISIBLE_MAP[x-1][y+1] = 1
				VISIBLE_MAP[x+1][y] = 1
				VISIBLE_MAP[x+1][y+1] = 1
				VISIBLE_MAP[x+1][y-1] = 1
			}
		}
	}
}

function update_memory_map() {
	for (y=0; y<world_height;y++) {
		for (x=0;x<world_width;x++) {
			MEMORY_MAP[x][y] = is_visible(x, y) || is_memorized(x, y)
		}
	}
}

function render_legend(   type, char, uniq_tiles, uniq_entities, front_color, back_colo, i, x, y) {
	uniq_entities = ""
	uniq_tiles = ""

	put_color("      LEGEND      ", screen_width-18, 1, "black", "white")

	for (i=0; i<nr_of_entities();i++) {
        x = ENTITIES[i]["x"]
        y = ENTITIES[i]["y"]
		type = ENTITIES[i]["type"]
		char = ENTITY_DATA[type]["char"]
		if (!index(uniq_entities, char) && is_visible(x, y)) {
			uniq_entities = uniq_entities char
		}
	}

	for (y=0; y<=viewport_height;y++) {
		for (x=0;x<=viewport_width;x++) {
			char = WORLD_MAP[x][y]
			if (!index(uniq_tiles, char) && is_visible(x, y)) {
				uniq_tiles = uniq_tiles char
			}
		}
	}

	x = screen_width - 18
			
	for (i=1; i<=length(uniq_entities);i++) {
		char = substr(uniq_entities,i,1)
		type = ENTITY_DATA[char]["type"]
		color = ENTITY_DATA[type]["color"]
		y = i + 2
		setch_color(char, x, y, color, "black")
		put_color(type, x+4, y, "white", "black")
	}
	
	for (i=1; i<=length(uniq_tiles);i++) {
		char = substr(uniq_tiles,i,1)
		type = TILE_DATA[char]["type"]
		front_color = TILE_DATA[type]["front_color"]
		back_color = TILE_DATA[type]["back_color"]
		y = i + length(uniq_entities) + 3
		setch_color(char, x, y, front_color, back_color)
		put_color(type, x+4, y, "white", "black")
	}
}

function render_info_menu(   x, pointer_char) {
	pointer_char = SCREEN_BUFFER[POINTER_X][POINTER_Y]
	pointer_char = substr(pointer_char, length(pointer_char), 1)
	
	put_color("     EXAMINE      ", screen_width-18, 1, "black", "white")

	if (is_item(pointer_char)) {
		# TODO
	} else if (is_tile(pointer_char)) {
		name = TILE_DATA[pointer_char]["type"]
		draw_art("tile", name, screen_width-18, 10)
		put_color(TILE_DATA[name]["type"], screen_width-13, screen_height-10+8, "white", "black")
	} else if (is_entity(pointer_char)) {
		name = ENTITY_DATA[pointer_char]["type"]
		draw_art("entity", name, screen_width-18, 10)
		put_color("HP", screen_width-18, screen_height-10+5, "white", "black")
		for (x=0;x<12;x++) {
			put_color(" ", screen_width-14+x, screen_height-10+5, "black", "forest_green")
		}
		put_color(ENTITY_DATA[name]["cry"], screen_width-13, screen_height-10+8, "white", "black")
	}
}

function render_character_menu() {
	put_color("    CHARACTER     ", screen_width-18, 1, "black", "white")
	draw_art("entity", "player", screen_width-17, 3)
	put_color("HP", screen_width-17, 12, "white", "black")
	for (x=0;x<13;x++) {
		put_color(" ", screen_width-14+x, 12, "black", "forest_green")
	}
	put_color("MP", screen_width-17, 13, "white", "black")
	for (x=0;x<13;x++) {
		put_color(" ", screen_width-14+x, 13, "black", "midnight_blue")
	}
}

function render_kb_shortcuts(   y, text_color, background_color) {
	y = screen_height-2
	text_color = "midnight_blue"
	background_color = "light_steel_blue"
	put_color(" (L)egend ", 3, y, text_color, background_color)
	put_color(" (C)haracter ", 15, y, text_color, background_color)
	put_color(" (I)nventory ", 30, y, text_color, background_color)
	put_color(" (Esc) Quit ", 45, y, text_color, background_color)
}

function render_tile(world_x, world_y, screen_x, screen_y) {
	if (screen_x >= viewport_width || screen_y >= viewport_height) {
		return
	}

	if (is_visible(world_x, world_y) || is_memorized(world_x, world_y)) {
		char = WORLD_MAP[world_x][world_y]
		
		if (!is_visible(world_x, world_y) && is_memorized(world_x, world_y)) {
			front_color = "dim_gray"
			back_color = TILE_DATA[char]["back_color"]
		} else {
			front_color = TILE_DATA[char]["front_color"]
			back_color = TILE_DATA[char]["back_color"]
		}
		
		put_color(char, screen_x, screen_y, front_color, back_color)
	}
}

function render(entity_idx,    x, y) {
	hide_cursor()
	x = ENTITIES[entity_idx]["x"]
	y = ENTITIES[entity_idx]["y"]

    clear_buffer()
	calculate_room_LOS()
    update_memory_map()
	camera_view(x, y)
	
	render_menu()
	#render_info_menu()
	
	flip_buffer()
	draw_cursor()
}
function render_menu() {
	render_kb_shortcuts()

	if (CURRENT_MENU == "legend") {
		render_legend()
	} else if (CURRENT_MENU == "character") {
		render_character_menu()
	} else if (CURRENT_MENU == "inventory") {
		# TODO
	}
}

function draw_cursor() {
	x = POINTER_X
	y = POINTER_Y

	if (!(x == middle_viewport_x && y == middle_viewport_y)) {
		show_cursor()
		printf("\033[%s;%sH", y+1, x)
		printf("\033[1;5m")
	} 
}

function draw_art(type, name, x_pos, y_pos,   x, y, char) {
	for (y=0;y<8;y++) {
		for (x=0;x<8;x++) {
			if (type == "entity" ) {
				char = ENTITY_DATA[name]["art"][x][y]
			} else if (type=="tile") {
				char = TILE_DATA[name]["art"][x][y]
			} else if (type=="item") {
				char = ITEM_DATA[name]["art"][x][y]
			} else {
				char = " "
			}
			
			# Draw char twice horizontally to make up for larger tile height
			setch(char, x_pos+x*2, y_pos+y)
			setch(char, x_pos+x*2+1, y_pos+y)
		}
	}
	
}

function render_to_file(entity_idx,   x, y) {
	x = ENTITIES[entity_idx]["x"]
	y = ENTITIES[entity_idx]["y"]

    clear_buffer()
	calculate_room_LOS()
    update_memory_map()
	camera_view(x, y)
	
	for (y=0; y<screen_height;y++) {
		output = ""
		for (x=0;x<screen_width;x++) {
            if (SCREEN_BUFFER[x][y] != CURRENT_SCREEN[x][y]) {
		        output = blahs
				CURRENT_SCREEN[x][y] = SCREEN_BUFFER[x][y]
			}
		}
		line = line 
	}

}

function get_screen_x(world_x, focus_x) {
	screen_x = x - (focus_x - middle_viewport_x)	
	return screen_x
}

function get_screen_y(world_y, focus_y) {
	screen_y = y - (focus_y - middle_viewport_y)
	return screen_y
}

function camera_view(focus_x, focus_y) {
	# Draw tiles
	for(x=max(0, focus_x - viewport_width); x < min(focus_x+viewport_width, world_width); x++) {
		for(y=max(0, focus_y - viewport_height); y < min(focus_y+viewport_height, world_height); y++) {
			char = WORLD_MAP[x][y]
			screen_x = get_screen_x(x, focus_x)
            screen_y = get_screen_y(y, focus_y)
			render_tile(x, y, screen_x, screen_y)
		}
	}

	# Draw entities
	for (i=0; i<nr_of_entities();i++) {
		x = ENTITIES[i]["x"]
		y = ENTITIES[i]["y"]
        if (is_visible(x, y)) {
            type = ENTITIES[i]["type"]
            char = ENTITY_DATA[type]["char"]
            front_color = ENTITY_DATA[type]["color"]
			screen_x = get_screen_x(x, focus_x)
			screen_y = get_screen_y(y, focus_y)
            put_color(char, screen_x, screen_y, front_color, 0)
        }
	}
}