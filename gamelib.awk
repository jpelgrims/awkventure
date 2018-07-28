# >>> AWKVENTURE GAME FUNCTIONALITY <<<

# Contains all functions and globals associated with game functionality

BEGIN {
	# Globals initialization
	init(ITEMS)
	init(ENTITIES)
	init(INVENTORY)

	MESSAGE_LOG[0] = ""

	world_width = 0
	world_height = 0
	level = 0
}

function add_entity(type, pos_x, pos_y, id, idx) {
	idx = nr_of_entities()

	ENTITIES[idx]["type"] = type
	ENTITIES[idx]["x"] = pos_x
	ENTITIES[idx]["y"] = pos_y
	ENTITIES[idx]["hp"] = ENTITY_DATA[type]["hp"]	

	ENTITY_ID_TO_INDEX[id] = idx
	return idx
}

function entity_exists(id) {
	return ENTITY_ID_TO_INDEX[id]
}

function get_entity_index(id) {
	return ENTITY_ID_TO_INDEX[id]
}

function add_message(message,   i) {
	for(i=3; i>=0; i--) {
		MESSAGE_LOG[i+1] = MESSAGE_LOG[i]
	}

	MESSAGE_LOG[0] = message

}

function add_tile(type, pos_x, pos_y) {

}

function add_item(type, pos_x, pos_y, id, idx) {
	idx = nr_of_items()

	ITEMS[idx]["type"] = type
	ITEMS[idx]["x"] = pos_x
	ITEMS[idx]["y"] = pos_y

	ITEM_ID_TO_INDEX[id] = idx
	return idx
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

function is_blocked(x, y, type,    char, entity_blocked, tile_blocked, i) {
	entity_blocked = 0
	tile_blocked = 0
	item_blocked = 0

	for (i=0; i<nr_of_entities(); i++) {
		if (ENTITIES[i]["x"] == x && ENTITIES[i]["y"] == y && ENTITIES[i]["hp"] > 0) {
			entity_blocked = 1
		}
	}

	for (i=0; i<nr_of_items(); i++) {
		if (ITEMS[i]["x"] == x && ITEMS[i]["y"] == y && !ITEMS[i]["picked_up"]) {
			item_blocked = 1
		}
	}

	char = WORLD_MAP[x][y]
	tile_blocked = TILE_DATA[char]["blocked"] == "true"

	if (type == "tile") {
		return tile_blocked
	} else if (type == "entity") {
		return entity_blocked
	} else if (type == "item") {
		return item_blocked
	} else {
		return tile_blocked || entity_blocked || item_blocked
	}
}

function activate_tile(activator_id, x, y) {

} 

function add_to_inventory(item_type) {
	if (len(INVENTORY) <= 10) {
		append(INVENTORY, item_type)
	}
}

function drop_item(   item_type, x, y) {
	if (len(INVENTORY) > 0) {
		item_type = INVENTORY[INVENTORY_SELECTION]
		x = ENTITIES[0]["x"]
		y = ENTITIES[0]["y"]
		add_item(item_type, x, y)
		remove(INVENTORY, INVENTORY_SELECTION)
		add_message("You dropped the " item_type "!")
	}
}

function use_item(   item_type, message, entity_type, entity_max_health, current_health) {
	if (len(INVENTORY) > 0) {
		item_type = INVENTORY[INVENTORY_SELECTION]
		effect = ITEM_DATA[item_type]["effect"]

		message = "You used the " item_type ". "

		if (effect == "heal") {
			entity_type = ENTITIES[user_id]["type"]
			entity_max_health = ENTITY_DATA[entity_type]["hp"]
			ENTITIES[user_id]["hp"] = entity_max_health
			message = message "You health was restored!"
		} else if (effect == "sicken") {
			current_health = ENTITIES[user_id]["hp"]
			ENTITIES[user_id]["hp"] = int(current_health / 2)
			message = message "You feel sick!"
		} else {
			message = message "Nothing happens!"
		}

		add_message(message)
		remove(INVENTORY, INVENTORY_SELECTION)
	}
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

function handle_input(idx, key,    str, entity_id, dx, dy, world_x, world_y) {
	if (length(key) != 0) {

		x = ENTITIES[idx]["x"]
		y = ENTITIES[idx]["y"]
		hp = ENTITIES[idx]["hp"]
		
		if (key == KEY["UP"] || match(key, /\033\[A/)) { dy-- }  
		else if (key == KEY["DOWN"] || match(key, /\033\[B/)) { dy++ } 
		else if (key == KEY["LEFT"] || match(key, /\033\[D/)) { dx-- } 
		else if (key == KEY["RIGHT"] || match(key, /\033\[C/)) { dx++} 
		else if (key == KEY["QUIT"] || match(key, /^\033$/)) {
			# Close any open menus, otherwiste close game
			if (CURRENT_MENU != "") {
				CURRENT_MENU = ""
			} else {
				RUNNING = 0
			}
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
		} else if (match(key, /-/)) {
			INVENTORY_SELECTION = max(0, INVENTORY_SELECTION-1)
		} else if (match(key, /+/)) {
			INVENTORY_SELECTION = min(INVENTORY_SELECTION+1, max(0, len(INVENTORY)-1))
		} else if (match(key, /\//)) {
			drop_item()
		} else if (match(key, /u/)) {
			use_item()
		} else if (match(key, /r/) && hp > 0) {
			world_x = get_world_x(POINTER_X, x)
			world_y = get_world_y(POINTER_Y, y)
			entity_id = get_entity_at(world_x, world_y)
			if (entity_id != "" && entity_id != 0) {
				attack_entity(entity_id, 0)
			}
		}
		
		if ((dx || dy) && !is_blocked(x+dx, y+dy) && hp > 0) {
			# Move player
			ENTITIES[idx]["x"] += dx
			ENTITIES[idx]["y"] += dy
			# Set Pointer position to player position
			POINTER_X = middle_viewport_x
			POINTER_Y = middle_viewport_y
		} else if ((dx || dy) && is_blocked(x+dx, y+dy, "entity") && hp > 0) {
			entity_id = get_entity_at(x+dx, y+dy)
			if (entity_id != "") {
				attack_entity(entity_id, 0)
			}
		} else if ((dx || dy) && is_blocked(x+dx, y+dy, "item") && hp > 0) {
			item_id = get_item_at(x+dx, y+dy)
			item_type = ITEMS[item_id]["type"]
			if (item_id != "") {
				ITEMS[item_id]["picked_up"] = 1
				add_to_inventory(item_type)
				add_message("You picked up the " item_type "!")
			}
			ENTITIES[idx]["x"] += dx
			ENTITIES[idx]["y"] += dy
		}

		if ((dx||dy) || match(key, /r/)) {
			return 1
		} else {
			return 0
		}
	}
}

function nr_of_entities() {
	return length(ENTITIES)-1
}

function nr_of_items() {
	return length(ITEMS)-1
}

function get_item_at(x, y,   i) {
	for (i=0;i<nr_of_items(); i++) {
		if (ITEMS[i]["x"] == x && ITEMS[i]["y"] == y) {
			return i
		}
	}
	return ""
}

function get_entity_at(x, y,    i) {
	# TODO: transform screen coords back to world coords and use that to get entity at x, y
	for (i=0;i<nr_of_entities(); i++) {
		if (ENTITIES[i]["x"] == x && ENTITIES[i]["y"] == y) {
			return i
		}
	}
	return ""
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

function attack_entity(entity_id, attacker_id,    type, damage, str) {
	attacker_type = ENTITIES[attacker_id]["type"]
	defender_type = ENTITIES[entity_id]["type"]
	str = ENTITY_DATA[attacker_type]["str"]
	damage = randint(0, str)
	ENTITIES[entity_id]["hp"] -= damage

	if (entity_id == 0) {
		player_hp = ENTITIES[0]["hp"]
		message = "The " attacker_type " attacks you"

		if (damage == 0) {
			message = message ". The " attacker_type " misses! "
		} else {
			message = message " (-" damage " HP). "
		}
		
		if (player_hp <= 0) {
			message = message "You die!"
		}

		add_message(message)
	} else if (attacker_id == 0) {
		entity_hp = ENTITIES[entity_id]["hp"]
		message = "You attack the " defender_type 

		if (damage == 0) {
			message = message ". You miss!"
		} else {
			message = message " (-" damage " HP)"
		}

		if (entity_hp <= 0) {
			message = message ". The " defender_type " died!"
		}
		add_message(message)

		if (entity_hp <= 0) {
			drop_loot(ENTITIES[entity_id]["x"], ENTITIES[entity_id]["y"], defender_type)
		}
		
	}

}

function drop_loot(x, y, from_entity,   item_index, item_type) {
	if (chance(50)) {
		item = randchar(ITEM_DATA["CHARSET"])
		item_type = ITEM_DATA[item]["type"]
		add_item(item_type, x, y)
		add_message("The " from_entity " dropped a " item_type "!")
	}
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
	player_hp = ENTITIES[0]["hp"]

	distance_to_player = entity_distance(entity_id, ENTITIES[0]["x"], ENTITIES[0]["y"])

	if (distance_to_player == 1 && player_hp > 0) {
		attack_entity(0, entity_id)
	} else if (distance_to_player <= 10 && player_hp > 0) {
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

function spawn_items() {
	# TODO
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