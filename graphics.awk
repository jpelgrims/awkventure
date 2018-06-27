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

function render_legend(   type, char, uniq_tiles, uniq_entities, front_color, back_color) {
	uniq_entities = ""
	uniq_tiles = ""

	for (i=0;i<screen_height;i++) {
		setch("              ", screen_width- 18, i)
	}

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
		y = i
		setch_color(char, x, y, color, "black")
		setch_color(type "    ", x+4, y, "white", "black")
	}
	
	for (i=1; i<=length(uniq_tiles);i++) {
		char = substr(uniq_tiles,i,1)
		type = TILE_DATA[char]["type"]
		front_color = TILE_DATA[type]["front_color"]
		back_color = TILE_DATA[type]["back_color"]
		y = i + length(uniq_entities) + 1
		setch_color(char, x, y, front_color, back_color)
		setch_color(type "    ", x+4, y, "white", "black")
	}
}

function render_tile(world_x, world_y, screen_x, screen_y) {
	if (is_visible(world_x, world_y) || is_memorized(world_x, world_y)) {
		char = WORLD_MAP[world_x][world_y]
		
		if (!is_visible(world_x, world_y) && is_memorized(world_x, world_y)) {
			front_color = "dim_gray"
			back_color = TILE_DATA[char]["back_color"]
		} else {
			front_color = TILE_DATA[char]["front_color"]
			back_color = TILE_DATA[char]["back_color"]
		}
		
		setch_color(char, screen_x, screen_y, front_color, back_color)
	}
}

function render() {
	player_x = ENTITIES[0]["x"]
	player_y = ENTITIES[0]["y"]

    clear_buffer()
	calculate_room_LOS()
    update_memory_map()
	camera_view(player_x, player_y)
	render_legend()
	flip_buffer()
}

function get_screen_x(world_x, focus_x) {
	middle_viewport_x = int(viewport_width/2)
	screen_x = x - (focus_x - middle_viewport_x)	
	return screen_x
}

function get_screen_y(world_y, focus_y) {
	middle_viewport_y = int(viewport_height/2)
	screen_y = y - (focus_y - middle_viewport_y)
	return screen_y
}

function camera_view(focus_x, focus_y) {
	# Draw tiles
	for(x=max(0, focus_x - viewport_width); x < min(focus_x+viewport_width, world_width); x++) {
		for(y=max(0, focus_y - viewport_height); y < max(focus_y+viewport_height, world_height); y++) {
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
            setch_color(char, screen_x, screen_y, front_color, 0)
        }
	}
}