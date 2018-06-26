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
			if (!index(uniq_tiles, char) && char && is_visible(x, y)) {
				uniq_tiles = uniq_tiles char
			}
		}
	}
			
	for (i=1; i<=length(uniq_entities);i++) {
		char = substr(uniq_entities,i,1)
		type = ENTITY_DATA[char]["type"]
		color = ENTITY_DATA[type]["color"]
		x = screen_width - 18
		y = i
		setch_color(char, x, y, color, "black")
		setch_color("   " type, x+1, y, "white", "black")
	}

	for (i=1; i<=length(uniq_tiles);i++) {
		char = substr(uniq_tiles,i,1)
		type = TILE_DATA[char]["type"]
		front_color = TILE_DATA[type]["front_color"]
		back_color = TILE_DATA[type]["back_color"]
		x = screen_width - 18
		y = i + length(uniq_entities) + 1
		setch_color(char, x, y, front_color, back_color)
		setch_color("   " type, x+1, y, "white", "black")
	}
}

function clear_buffer() {
	for (y=0; y<screen_height;y++) {
		for (x=0;x<screen_width;x++) {
			setch(" ", x, y)
		}
	}
}

function render_worldmap(   x, y, char, front_color, back_color) {
	for (y=0; y<=viewport_height;y++) {
		for (x=0;x<=viewport_width;x++) {
			if (is_visible(x, y) || is_memorized(x, y)) {
				char = WORLD_MAP[x][y]
				
                if (!is_visible(x, y) && is_memorized(x, y)) {
                    front_color = "grey"
				    back_color = TILE_DATA[char]["back_color"]
                } else {
                    front_color = TILE_DATA[char]["front_color"]
				    back_color = TILE_DATA[char]["back_color"]
                }
                
				setch_color(char, x, y, front_color, back_color)
			}
		}
	}
}

function render_entities(   i, x, y, type, char, front_color) {
	for (i=0; i<nr_of_entities();i++) {
		x = ENTITIES[i]["x"]
		y = ENTITIES[i]["y"]
        if (is_visible(x, y)) {
            type = ENTITIES[i]["type"]
            char = ENTITY_DATA[type]["char"]
            front_color = ENTITY_DATA[type]["color"]
            setch_color(char, x, y, front_color, 0)
        }

	}
}

function render() {
    clear_buffer()
	calculate_room_LOS()
    update_memory_map()
    render_worldmap()
    render_entities()
	render_legend()
	flip_buffer()
}

function camera_view() {

}