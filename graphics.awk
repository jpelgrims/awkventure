BEGIN {
	POINTER_X = 0
	POINTER_Y = 0

	CURRENT_MENU = "legend"

	INVENTORY_SELECTION = 0

	viewport_height = screen_height
	viewport_width = screen_width

	middle_viewport_x = int(viewport_width/2)
	middle_viewport_y = int(viewport_height/2)
}

function draw_line_dda(x1, y1, x2, y2,   dx, dy, x, y, v, x_incr, y_incr, char) {
	dx = abs(x2-x1)
	dy = abs(y2-y1)

	if (dx >= dy) {
		steps = dx
	} else {
		steps = dy
	}

	if (steps == 0) {
		# Do nothing
	} else {
		x_incr = (x2-x1) / steps
		y_incr = (y2-y1) / steps

		x = x1 
		y = y1

		for (v=0;v < steps; v++) {
			x += x_incr
			y += y_incr
			cur_x = round(x)
			cur_y = round(y)
			char = get_character(cur_x,cur_y)
			console_write(char, cur_x, cur_y, "light_sky_blue", "selection_gray")
			# TODO do this properly
			if (char == "#") {
				break
			}
		}
	}
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

function draw_menu_canvas(menu_title, menu_height,    x, y) {
	console_write(menu_title, screen_width-19, 1, "black", "light_steel_blue")

	for(x=0; x<18;x++) {
		for(y=0; y<menu_height;y++) {
			console_write(" ", screen_width-x-2, y+2, "black", "menu_gray")
		}
	}
}

function render_legend(   type, char, uniq_tiles, uniq_entities, uniq_items, front_color, back_color, color, i, x, y, menu_height) {
	uniq_entities = ""
	uniq_tiles = ""

	# Enumerate different types of visible tiles, entities and items

	for (i=0; i<nr_of_entities();i++) {
        x = ENTITIES[i]["x"]
        y = ENTITIES[i]["y"]
		type = ENTITIES[i]["type"]
		char = ENTITY_DATA[type]["char"]
		if (!index(uniq_entities, char) && is_visible(x, y) && ENTITIES[i]["hp"] > 0) {
			uniq_entities = uniq_entities char
		}
	}

	for (i=0; i<nr_of_items();i++) {
        x = ITEMS[i]["x"]
        y = ITEMS[i]["y"]
		type = ITEMS[i]["type"]
		char = ITEM_DATA[type]["char"]
		if (!index(uniq_items, char) && is_visible(x, y) && !ITEMS[i]["picked_up"]) {
			uniq_items = uniq_items char
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

	# Draw menu

	menu_height = length(uniq_entities) + length(uniq_tiles) + length(uniq_items) + 3
	if (length(uniq_items) > 0) { menu_height += 1}

	draw_menu_canvas("      LEGEND      ", menu_height)

	x = screen_width - 19

	for (i=1; i<=length(uniq_entities);i++) {
		char = substr(uniq_entities,i,1)
		type = ENTITY_DATA[char]["type"]
		color = ENTITY_DATA[type]["color"]
		y = i + 2
		console_write(char, x+2, y, color, "menu_gray")
		console_write(type, x+4, y, "white", "menu_gray")
	}

	for (i=1; i<=length(uniq_items);i++) {
		char = substr(uniq_items,i,1)
		type = ITEM_DATA[char]["type"]
		color = ITEM_DATA[type]["color"]
		y = i + length(uniq_entities) + 2
		if (length(uniq_entities) > 0) { y += 1 }
		console_write(char, x+2, y, color, "menu_gray")
		console_write(type, x+4, y, "white", "menu_gray")
	}
	
	for (i=1; i<=length(uniq_tiles);i++) {
		char = substr(uniq_tiles,i,1)
		type = TILE_DATA[char]["type"]
		front_color = TILE_DATA[type]["front_color"]
		back_color = TILE_DATA[type]["back_color"]
		y = i + length(uniq_entities) +  length(uniq_items) + 2
		if (length(uniq_entities) > 0) { y += 1 }
		if (length(uniq_items) > 0) { y += 1 }
		console_write(char, x+2, y, front_color, back_color)
		console_write(type, x+4, y, "white", "menu_gray")
	}
}

function render_info_menu(   x, pointer_char) {
	pointer_char = SCREEN_BUFFER[POINTER_X][POINTER_Y]
	pointer_char = substr(pointer_char, length(pointer_char), 1)
	
	console_write("     EXAMINE      ", screen_width-18, 1, "black", "white")

	if (is_item(pointer_char)) {
		# TODO
	} else if (is_tile(pointer_char)) {
		name = TILE_DATA[pointer_char]["type"]
		draw_art("tile", name, screen_width-18, 10)
		console_write(TILE_DATA[name]["type"], screen_width-13, screen_height-10+8, "white", "black")
	} else if (is_entity(pointer_char)) {
		name = ENTITY_DATA[pointer_char]["type"]
		draw_art("entity", name, screen_width-18, 10)
		console_write("HP", screen_width-18, screen_height-10+5, "white", "black")
		for (x=0;x<12;x++) {
			console_write(" ", screen_width-14+x, screen_height-10+5, "black", "forest_green")
		}
		console_write(ENTITY_DATA[name]["cry"], screen_width-13, screen_height-10+8, "white", "black")
	}
}

function render_inventory_menu(   menu_height, x, idx, i, item_type, char) {
	menu_height = len(INVENTORY) + 2
	draw_menu_canvas("     INVENTORY    ", menu_height)
	x = screen_width - 19

	for (i=0; i<len(INVENTORY);i++) {
		item_type = INVENTORY[i]
		char = ITEM_DATA[item_type]["char"]
		color = ITEM_DATA[item_type]["color"]
		console_write(char, x+4, 3+i, color, "menu_gray")
		console_write(item_type, x+6, 3+i, "white", "menu_gray")

		if (i == INVENTORY_SELECTION) {
			console_write(">", x+2, 3+INVENTORY_SELECTION, "light_steel_blue", "menu_gray")
		}
	}
}

function render_character_menu() {
	console_write("    CHARACTER     ", screen_width-19, 1, "black", "light_steel_blue")

	menu_height = 13
	for(x=0; x<18;x++) {
		for(y=0; y<menu_height;y++) {
			console_write(" ", screen_width-x-2, y+2, "black", "menu_gray")
		}
	}

	draw_art("entity", "player", screen_width-18, 3)
	console_write("HP", screen_width-17, 12, "menu_white", "menu_gray")
	for (x=0;x<11;x++) {
		console_write(" ", screen_width-14+x, 12, "black", "forest_green")
	}
	max_hp = ENTITY_DATA["player"]["hp"]
	current_hp = ENTITIES[0]["hp"]
	console_write(current_hp "/" max_hp, screen_width-14+2, 12, "black", "forest_green")

	console_write("MP", screen_width-17, 13, "menu_white", "menu_gray")
	for (x=0;x<11;x++) {
		console_write(" ", screen_width-14+x, 13, "black", "midnight_blue")
	}
}

function render_kb_shortcuts(   y, text_color, background_color) {
	y = screen_height-2
	text_color = "midnight_blue"
	background_color = "light_steel_blue"
	console_write(" (L)egend ", 3, y, text_color, background_color)
	console_write(" (C)haracter ", 15, y, text_color, background_color)
	console_write(" (I)nventory ", 30, y, text_color, background_color)
	console_write(" (Esc) Quit ", 45, y, text_color, background_color)
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
		
		console_write(char, screen_x, screen_y, front_color, back_color)
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
	draw_line_dda(middle_viewport_x, middle_viewport_y, POINTER_X, POINTER_Y)
	render_menu()
	render_message_log()
	#render_info_menu()
	
	merge_buffer_layers()
	flip_buffer()
	draw_cursor()
}

function render_message_log(   i, color) {
	log_length = length(MESSAGE_LOG)
	for (i=0;i<log_length;i++) {
		color = sprintf("%s,%s,%s", 250-50*i, 250-50*i, 250-50*i)
		console_write(MESSAGE_LOG[i], 2, i, color)
	}
}

function render_menu() {
	render_kb_shortcuts()

	switch(CURRENT_MENU) {
		case "legend":
			render_legend(); break
		case "character":
			render_character_menu(); break
		case "inventory":
			render_inventory_menu(); break
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
				color = ENTITY_DATA[name]["art"][x][y]
			} else if (type=="tile") {
				color = TILE_DATA[name]["art"][x][y]
			} else if (type=="item") {
				color = ITEM_DATA[name]["art"][x][y]
			} else {
				color = "30,30,30"
			}
			# Draw char twice horizontally to make up for larger tile height
			console_write(" ", x_pos+x*2, y_pos+y, "255,255,255", color)
			console_write(" ", x_pos+x*2+1, y_pos+y, "255,255,255", color)
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

function get_screen_x(world_x, focus_x,    screen_x) {
	screen_x = x - (focus_x - middle_viewport_x)	
	return screen_x
}

function get_screen_y(world_y, focus_y,    screen_y) {
	screen_y = y - (focus_y - middle_viewport_y)
	return screen_y
}

function get_world_x(screen_x, focus_x,    world_x) {
	world_x = screen_x + (focus_x - middle_viewport_x)
	return world_x
}

function get_world_y(screen_y, focus_y,    world_y) {
	world_y = screen_y + (focus_y - middle_viewport_y)
	return world_y
}

function camera_view(focus_x, focus_y,   char) {
	# Draw tiles
	for(x=max(0, focus_x - viewport_width); x < min(focus_x+viewport_width, world_width); x++) {
		for(y=max(0, focus_y - viewport_height); y < min(focus_y+viewport_height, world_height); y++) {
			char = WORLD_MAP[x][y]
			screen_x = get_screen_x(x, focus_x)
            screen_y = get_screen_y(y, focus_y)
			render_tile(x, y, screen_x, screen_y)
		}
	}

	# Draw corpses
	for (i=0; i<nr_of_entities();i++) {
		x = ENTITIES[i]["x"]
		y = ENTITIES[i]["y"]
		if (ENTITIES[i]["hp"] <= 0 && is_visible(x, y)) {
			screen_x = get_screen_x(x, focus_x)
			screen_y = get_screen_y(y, focus_y)
			console_write(";", screen_x, screen_y, "white")
		}
	}

	# Draw items
	for (i=0; i<nr_of_items();i++) {
		x = ITEMS[i]["x"]
		y = ITEMS[i]["y"]

		if (is_visible(x, y) && !ITEMS[i]["picked_up"]) {
			type = ITEMS[i]["type"]
			char = ITEM_DATA[type]["char"]
			color = ITEM_DATA[type]["color"]
			screen_x = get_screen_x(x, focus_x)
			screen_y = get_screen_y(y, focus_y)
			console_write(char, screen_x, screen_y, color)
		}
	}

	# Draw entities
	for (i=0; i<nr_of_entities();i++) {
		x = ENTITIES[i]["x"]
		y = ENTITIES[i]["y"]

		if (ENTITIES[i]["hp"] > 0 && is_visible(x, y)) {
			type = ENTITIES[i]["type"]
			char = ENTITY_DATA[type]["char"]
			front_color = ENTITY_DATA[type]["color"]
			screen_x = get_screen_x(x, focus_x)
			screen_y = get_screen_y(y, focus_y)
			console_write(char, screen_x, screen_y, front_color)
		}
	}

}