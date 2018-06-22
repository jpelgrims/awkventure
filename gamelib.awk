function add_entity(type, pos_x, pos_y) {
	id = nr_of_entities()
	entities[id]["type"] = type
	entities[id]["x"] = pos_x
	entities[id]["y"] = pos_y
	entities["length"]++
	return id
}

function add_tile(type, pos_x, pos_y) {

}

function add_item(type, pos_x, pos_y) {

}


function is_blocked(x, y) {
	for (i=0; i<nr_of_entities(); i++) {
		
		if (entities[i]["x"] == x && entities[i]["y"] == y) {
			return 1
		}
	}

	char = WORLD_MAP[x][y]
	return TILE_DATA[char]["blocked"] == "true"
}

function activate_tile(activator_id, x, y) {

}

function use_item(user_id, item) {

}

function handle_input(key) {
	if (length(key) != 0) {
		
		x = entities[0]["x"]
		y = entities[0]["y"]
		
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
			entities[0]["x"] = x
			entities[0]["y"] = y
		}
	}
}

function nr_of_entities() {
	return entities["length"]
}

function render() {
	# Render world
	for (y=0; y<=world_height;y++) {
		for (x=0;x<=world_width;x++) {
			setch(WORLD_MAP[x][y], x, y)
		}
	}

	# Render entities
	for (i=0; i<nr_of_entities();i++) {
		type = entities[i]["type"]
		x = entities[i]["x"]
		y = entities[i]["y"]
		char = ENTITY_DATA[type]["char"]
		setch(char, x, y)
	}
}

function camera_view() {

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