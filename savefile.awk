function save_game(   i, x, y, hp, type, save_file) {
    save_file = "savefile.sav"

    # Save general game settings
    print "" > save_file
    print "[SAVE GENERAL]" > save_file
    print "WORLD_WIDTH=" world_width > save_file
    print "WORLD_HEIGHT=" world_height > save_file
    print "GAME_LEVEL=" GAME_LEVEL > save_file
    print "CURRENT_LEVEL=" CURRENT_LEVEL > save_file
    print "CURRENT_EXPERIENCE=" CURRENT_EXPERIENCE > save_file

    # Save game entities
    print "" > save_file
    print "[SAVE ENTITIES]" > save_file
    print "id, type, x, y, hp" > save_file
    count = 0
    for (i in ENTITIES) {
        type = ENTITIES[i]["type"]
	    x = ENTITIES[i]["x"]
	    y = ENTITIES[i]["y"]
	    hp = ENTITIES[i]["hp"]
        print count "," type "," x "," y "," hp > save_file
        count++
    }

    # Save game items
    print "" > save_file
    print "[SAVE ITEMS]" > save_file
    print "id, type, x, y, picked_up" > save_file
    count = 0
    for (i in ITEMS) {
        type = ITEMS[i]["type"]
	    x = ITEMS[i]["x"]
	    y = ITEMS[i]["y"]
        picked_up = ITEMS[i]["picked_up"]
        print count "," type "," x "," y "," picked_up > save_file
        count++
    }

    # Save game tiles
    print "" > save_file
    print "[SAVE TILES]" > save_file
    for(y=0;y<world_height;y++) {
        line = ""
        for (x=0;x<world_width;x++) {
            line = line WORLD_MAP[x][y]
        }
        print line > save_file
    }

    # Save memory map
    print "" > save_file
    print "[SAVE MEMORY]" > save_file
    for(y=0;y<world_height;y++) {
        line = ""
        for (x=0;x<world_width;x++) {
            line = line MEMORY_MAP[x][y]
        }
        print line > save_file
    }

    # Save player inventory
    print "" > save_file
    print "[SAVE INVENTORY]" > save_file
    line = INVENTORY[1]
    for (i=2; i<=length(INVENTORY);i++) {
		line = line "," INVENTORY[i]
    }
    print line > save_file

    add_message("Your progress is saved.")
}

/^\[SAVE GENERAL\]/ {
	load_block(lines)

	for (i in lines) {
		split(lines[i],a,"=")
		key = trim(a[1])
		value = trim(a[2])
		globals[key] = value
	}

    world_width = globals["WORLD_WIDTH"]
    world_height = globals["WORLD_HEIGHT"]
    GAME_LEVEL = globals["GAME_LEVEL"]
    CURRENT_LEVEL = globals["CURRENT_LEVEL"]
    CURRENT_EXPERIENCE = globals["CURRENT_EXPERIENCE"]
}

function load_csv_savefile(storage_array) {
    getline

	split($0,headers,",")

	do {
		EOF = !getline
		if (EOF) {
			exit
		}

            for (i in headers) {
                headers[i] = trim(headers[i])
            }

		if (length($0) != 0) {
            split($0,a,",")
            
            id = trim(a[1])
            
			for (i in headers) {
				storage_array[id][headers[i]] = a[i]
			}
        
		}	
	} while (trim($0) != "")
}

function load_save_map(storage_array,   chars) {
	map_width = 0
	map_height = 0

	while(readline()) {
		line = $0
		
		if (map_width == 0) {
			map_width = length(line)
			for (x=0; x < map_width; x++) {
				storage_array[x][map_height] = substr(line, x, 1)
			}
			map_height++
		} else if (map_width != 0 && length(line) == map_width) {
			for (x=0; x < map_width; x++) {
				storage_array[x][map_height] = substr(line, x, 1)
			}
			map_height++
		} else {
			print "Game map is jagged, please check " FILENAME " for errors"
			system("sleep 5")
		}
	}
}

function savefile() {
    for(i in ARGV) {
        if (ARGV[i] == "savefile.sav") {
            return 1
        }
    }
    return 0
}

/^\[SAVE ENTITIES\]/ {
	load_csv_savefile(ENTITIES)
}

/^\[SAVE ITEMS\]/ {
	load_csv_savefile(ITEMS)
}

/^\[SAVE INVENTORY\]/ {
	getline
    split($0,INVENTORY,",")
}

/^\[SAVE TILES\]/ {
	load_save_map(WORLD_MAP)
}

/^\[SAVE MEMORY\]/ {
	load_save_map(MEMORY_MAP)
}