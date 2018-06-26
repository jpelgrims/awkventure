function add_entity(type, pos_x, pos_y) {
	id = nr_of_entities()
	ENTITIES[id]["type"] = type
	ENTITIES[id]["x"] = pos_x
	ENTITIES[id]["y"] = pos_y
	ENTITIES["length"]++
	return id
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

function is_blocked(x, y, type,    entity_blocked, tile_blocked) {
	entity_blocked = 0
	tile_blocked = 0

	for (i=0; i<nr_of_entities(); i++) {
		if (ENTITIES[i]["x"] == x && ENTITIES[i]["y"] == y) {
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

function handle_input(key) {
	if (length(key) != 0) {
		
		x = ENTITIES[0]["x"]
		y = ENTITIES[0]["y"]
		
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
			ENTITIES[0]["x"] = x
			ENTITIES[0]["y"] = y
		}
	}
}

function nr_of_entities() {
	return ENTITIES["length"]
}


function update() {

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