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


function handle_input(idx, key,    str, entity_id, dx, dy, world_x, world_y, x, y) {
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
				shutdown()
			}
		} else if (key == KEY["POINTER_UP"]) {
			POINTER_Y -= 1
		} else if (key == KEY["POINTER_DOWN"]) {
			POINTER_Y += 1
		} else if (key == KEY["POINTER_LEFT"]) {
			POINTER_X -= 1
		} else if (key == KEY["POINTER_RIGHT"]) {
			POINTER_X += 1
		} else if (key == KEY["LEGEND_MENU"]) {
			CURRENT_MENU = "legend"
		} else if (key == KEY["CHARACTER_MENU"]) {
			CURRENT_MENU = "character"
		} else if (key == KEY["INVENTORY_MENU"]) {
			CURRENT_MENU = "inventory"
		} else if (key == KEY["INVENTORY_POINTER_UP"]) {
			INVENTORY_SELECTION = max(0, INVENTORY_SELECTION-1)
		} else if (key == KEY["INVENTORY_POINTER_DOWN"]) {
			INVENTORY_SELECTION = min(INVENTORY_SELECTION+1, max(0, length(INVENTORY)-1))
		} else if (key == KEY["DROP_ITEM"]) {
			drop_item()
		} else if (key == KEY["USE_ITEM"]) {
			use_item()
		} else if (key == KEY["SAVE_GAME"]) {
			save_game()
		} else if (key == KEY["RANGED_ATTACK"] && hp > 0 && EQUIPMENT["ranged_weapon"]) {
			world_x = get_world_x(POINTER_X, x)
			world_y = get_world_y(POINTER_Y, y)
			entity_id = get_entity_at(world_x, world_y)
			if (entity_id != "" && entity_id != 0) {
				attack_entity(entity_id, 0)
			}
		}
		
		if ((dx || dy) && !is_blocked(x+dx, y+dy) && hp > 0) {
			# Move player and set cursor position
			move_entity(idx, dx, dy)
			set_pointer(middle_viewport_x, middle_viewport_y)
		} else if ((dx || dy) && is_blocked(x+dx, y+dy, "entity") && hp > 0) {
			entity_id = get_entity_at(x+dx, y+dy)
			if (entity_id != "") {
				attack_entity(entity_id, 0)
			}
		} else if ((dx || dy) && is_blocked(x+dx, y+dy, "item") && hp > 0) {
			item_id = get_item_at(x+dx, y+dy)
			item_type = ITEMS[item_id]["type"]
			ITEMS[item_id]["picked_up"] = 1
			add_to_inventory(item_id)
			add_message("You picked up the " item_type "!")
			move_entity(idx, dx, dy)
		}

		if ((dx||dy) || match(key, /r/)) {
			return 1
		} else {
			return 0
		}
	}
}

function read_input_file(keys,    i) {
	i = 0
	while (getline) {
		keys[i] = $0
		i += 1
	}
}