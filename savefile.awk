function save_game(   i, x, y, hp, type, save_file) {
    save_file = "savefile.sav"

    # Save general game settings
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
    for (i=0; i<nr_of_entities();i++) {
        type = ENTITIES[i]["type"]
	    x = ENTITIES[i]["x"]
	    y = ENTITIES[i]["y"]
	    hp = ENTITIES[i]["hp"]
        print i "," type "," x "," y "," hp > save_file
    }

    # Save game items
    print "" > save_file
    print "[SAVE ITEMS]" > save_file
    print "id, type, x, y" > save_file
    for (i=0; i<nr_of_items();i++) {
        type = ITEMS[i]["type"]
	    x = ITEMS[i]["x"]
	    y = ITEMS[i]["y"]
        print i "," type "," x "," y > save_file
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
}