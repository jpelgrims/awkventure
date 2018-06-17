# Function that loads csv foramtted lines into dict, with type and char as keys
function load_csv(storage_array) {
    getline

	split($0,headers,", ")

	do {
		EOF = !getline
		if (EOF) {
			exit
		}

            for (i in headers) {
                headers[i] = trim(headers[i])
            }

		if (length($0) != 0) {
            split($0,a,", ")
            
            type = trim(a[1])
            char = trim(a[2])
            
			for (i in headers) {
				storage_array[type][headers[i]] = a[i]
                storage_array[char][headers[i]] = a[i]
			}
        
		}	
	} while (trim($0) != "")
}

# Read line and check if it is an empty line
function readline() {
	EOF = !getline
	if (trim($0) == "") {
		return 0
	} else if (EOF) {
		return 2
	} else {
		return 1
	}
}

function load_script(   script) {
	script = "" 
	do {
		EOF = !getline
		if (EOF) {
			exit
		}

		script = script "\n" $0
	} while (trim($0) != "END_SCRIPT")
	return script
}

# Function that loads lines until an empty line is found
function load_block(storage_array,   y) {
	y = 0
	while (readline()) {
		storage_array[y] = $0
		y++
	}
}

# Function that loads .ini formatted lines
function load_ini(storage_array,   lines) {
	load_block(lines)

	for (i in lines) {
		split(lines[i],a,"=")
		key = trim(a[1])
		value = trim(a[2])
		storage_array[key] = value
	}
}

# Function that loads an ascii map
function load_map(level_nr,   map_width, map_height) {
	map_width = 0
	map_height = 0

	while(readline()) {
		line = $0
		
		if (map_width == 0) {
			map_width = length(line)
			for (x=0; x < map_width; x++) {
				world_maps[level_nr][x][map_height] = substr(line, x, 1)
			}
			map_height++
		} else if (map_width != 0 && length(line) == map_width) {
			for (x=0; x < map_width; x++) {
				world_maps[level_nr][x][map_height] = substr(line, x, 1)
			}
			map_height++
		} else {
			print "Game map is jagged, please check " FILENAME " for errors"
			system("sleep 5")
		}
	}

	world_maps[level_nr]["map_width"] = map_width
	world_maps[level_nr]["map_height"] = map_height
}