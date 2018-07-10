function add_entity(type, pos_x, pos_y, id, idx) {
	idx = nr_of_entities()

	ENTITIES[idx]["type"] = type
	ENTITIES[idx]["x"] = pos_x
	ENTITIES[idx]["y"] = pos_y
	ENTITIES[idx]["hp"] = ENTITY_DATA[type]["hp"]

	ENTITIES["length"]++
	

	ENTITY_ID_TO_INDEX[id] = idx
	return idx
}

function entity_exists(id) {
	return ENTITY_ID_TO_INDEX[id]
}

function get_entity_index(id) {
	return ENTITY_ID_TO_INDEX[id]
}



function add_tile(type, pos_x, pos_y) {

}

function add_item(type, pos_x, pos_y) {

}

function is_visible(x, y) {
	return VISIBLE_MAP[x][y] == 1
}

function is_memorized(x, y) {
	return MEMORY_MAP[x][y] == 1
}

function is_entity(char) {
	return index(ENTITY_DATA["CHARSET"], char)
}

function is_tile(char) {
	return index(TILE_DATA["CHARSET"], char)
}

function is_item(char) {
	return index(ITEM_DATA["CHARSET"], char)
}

function is_blocked(x, y, type,    char, entity_blocked, tile_blocked) {
	entity_blocked = 0
	tile_blocked = 0

	for (i=0; i<nr_of_entities(); i++) {
		if (ENTITIES[i]["x"] == x && ENTITIES[i]["y"] == y && ENTITIES[i]["hp"] > 0) {
			entity_blocked = 1
		}
	}

	char = WORLD_MAP[x][y]
	tile_blocked = TILE_DATA[char]["blocked"] == "true"

	if (type == "tile") {
		return tile_blocked
	} else if (type == "entity") {
		return entity_blocked
	} else {
		return tile_blocked || entity_blocked
	}
}

function activate_tile(activator_id, x, y) {

}

function use_item(user_id, item) {

}

function handle_multiplayer_input(keys,   i, a, id, key, idx) {

	for(i=0;i<length(keys);i++) {
		split(keys[i],a," ")
		id = a[1]
		key = a[2]

		if (!entity_exists(id)) {
			# Add check for location (see if not wall)
			add_entity("player", 2, 2, id)
		}

		idx = get_entity_index(id)
		handle_input(id, key)
	}


}

function handle_input(idx, key,    str, entity_id) {
	if (length(key) != 0) {

		x = ENTITIES[idx]["x"]
		y = ENTITIES[idx]["y"]
		
		if (key == KEY["UP"] || match(key, /\033\[A/)) { y-- }  
		else if (key == KEY["DOWN"] || match(key, /\033\[B/)) { y++ } 
		else if (key == KEY["LEFT"] || match(key, /\033\[D/)) { x-- } 
		else if (key == KEY["RIGHT"] || match(key, /\033\[C/)) { x++} 
		else if (key == KEY["QUIT"] || match(key, /^\033$/)) {
			RUNNING = 0
		} else if (match(key, /8/)) {
			POINTER_Y -= 1
		} else if (match(key, /2/)) {
			POINTER_Y += 1
		} else if (match(key, /4/)) {
			POINTER_X -= 1
		} else if (match(key, /6/)) {
			POINTER_X += 1
		} else if (match(key, /l/)) {
			CURRENT_MENU = "legend"
		} else if (match(key, /c/)) {
			CURRENT_MENU = "character"
		} else if (match(key, /i/)) {
			CURRENT_MENU = "inventory"
		}
		
		if (is_blocked(x, y) == 0) {
			# Move player
			ENTITIES[idx]["x"] = x
			ENTITIES[idx]["y"] = y
			# Set Pointer position to player position
			POINTER_X = middle_viewport_x
			POINTER_Y = middle_viewport_y
		} else if (is_blocked(x, y, "entity")) {
			str = ENTITY_DATA["player"]["str"]
			entity_id = get_entity_at(x, y)
			attack_entity(entity_id, str)
		}
	}
}

function nr_of_entities() {
	return length(ENTITIES)-1
}

function get_entity_at(x, y,    i) {
	# TODO: transform screen coords back to world coords and use that to get entity at x, y
	for (i=0;i<nr_of_entities(); i++) {
		if (ENTITIES[i]["x"] == x && ENTITIES[i]["y"] == y) {
			return i
		}
	}
	return 0
}


function update_entities(   i, x, y) {
	for (i=1;i<nr_of_entities();i++) {
		if (ENTITIES[i]["hp"] > 0) {
			move_towards_player(i)
		}
	}
}

function move_entity(id, dx, dy,    x, y) {
	x = ENTITIES[id]["x"] + dx 
	y = ENTITIES[id]["y"] + dy
	if (!is_blocked(x, y)) {
		ENTITIES[id]["x"] += dx
		ENTITIES[id]["y"] += dy
	}
}

function attack_entity(entity_id, str,    damage) {
	damage = randint(0, str)
	ENTITIES[entity_id]["hp"] -= damage
}

function move_randomly(entity_id,   dx, dy) {
	dx = randint(-1, 1)
	dy = randint(-1, 1)

	if (randint(0, 1)) {
		move_entity(entity_id, dx, 0)
	} else {
		move_entity(entity_id, 0, dy)
	}
}

function entity_distance(id, x_dest, y_dest,    distance) {
	x = ENTITIES[id]["x"]
	y = ENTITIES[id]["y"]
	distance = abs(x_dest - x) + abs(y_dest - y)
	return distance
}

function move_towards_player(entity_id,    x, y, dx, dy, type, str) {
	x = ENTITIES[entity_id]["x"]
	y = ENTITIES[entity_id]["y"]

	distance_to_player = entity_distance(entity_id, ENTITIES[0]["x"], ENTITIES[0]["y"])

	if (distance_to_player == 1) {
		type = ENTITIES[entity_id]["type"]
		str = ENTITY_DATA["type"]["str"]
		attack_entity(0, str)

	} else if (distance_to_player <= 10) {
		# Move towards player
		dx = 0
		dy = 0

		if (ENTITIES[0]["x"] > x) {
			dx = 1
		} else if (ENTITIES[0]["x"] < x) {
			dx = -1
		}

		if (ENTITIES[0]["y"] > y) {
			dy = 1
		} else if (ENTITIES[0]["y"] < y) {
			dy = -1
		}

		if (randint(0, 1)) {
			move_entity(entity_id, dx, 0)
		} else {
			move_entity(entity_id, 0, dy)
		}

	} else {
		move_randomly(entity_id)
	}



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

function spawn_monsters(   x, y, entity_char, toss, world_height, world_width, type) {
	world_width = WORLD_MAP["width"]
	world_height = WORLD_MAP["height"]
	for (y=0; y<world_height;y++) {
		for (x=0;x<world_width;x++) {
			toss = randint(0,100)
			if (toss >= 99 && !is_blocked(x, y)) {
				entity_char = randchar(ENTITY_DATA["CHARSET"])
				type = ENTITY_DATA[entity_char]["type"]
				add_entity(type, x, y)
			}
		}
	}
}

function set_level(level_nr) {

	# Load level map
	world_height = world_maps[level_nr]["map_height"]
	world_width = world_maps[level_nr]["map_width"]
	delete WORLD_MAP

	for (y=0; y<world_height;y++) {
		for (x=0;x<world_width;x++) {
			WORLD_MAP[x][y]=world_maps[level_nr][x][y]
		}
	}

	# Run level script
	run_script(scripts["level"][level_nr])

}

function read_input_file(keys,    i) {
	i = 0
	while (getline) {
		keys[i] = $0
		i += 1
	}
}