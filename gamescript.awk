# Game scripting

function run_script(script,    script_line, groups) {
    split(script,a,"\n")

	for (i in a) {
		script_line = a[i]

        # ADD_<TYPE> <name> <x>,<y>
		if (match(script_line, /^ADD_([A-Z]+) ([a-zA-Z]+) ([0-9]),([0-9])/, groups)) {

            if (groups[1] == "ENTITY") {
                add_entity(groups[2], groups[3], groups[4])
            } else if (groups[1] == "TILE") {
                add_tile(groups[2], groups[3], groups[4])
            } else if (groups[1] == "ITEM") {
                add_item(groups[2], groups[3], groups[4])
            }

		} 
        
        # SET_<ATTRIBUTE> <value>
        else if (match(script_line, /^SET_([A-Z]+) (.+)/, groups)) {
            entity_nr = length(entities)
            entities[entity_nr][tolower(groups[1])] = groups[2]
        }
	}
}