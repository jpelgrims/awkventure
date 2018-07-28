# >>> AWK CONSOLE DRAWING LIBRARY <<<

# Works with 3 buffers (front colors, back colors & characters).
# Merge all buffers with merge_buffer_layers() before using flip_buffer() to show the buffer on the console
# Write in buffer using console_write()


BEGIN {
    # CSS colors and associated RGB values
    COLOR["green"] = "0,255,0"
    COLOR["blue"] = "0,0,255"
    COLOR["red"] = "255,0,0"
    COLOR["white"] = "255,255,255"
    COLOR["black"] = "0,0,0"
    COLOR["grey"] = "169,169,169"
    COLOR["brown"] = "165,42,42"
    COLOR["yellow"] = "255,255,0"
    COLOR["dim_gray"] = "105,105,105"
    COLOR["royal_blue"] = "17,30,108"
    COLOR["yale_blue"] = "17,30,108"
    COLOR["dark_slate_gray"] = "47,79,79"
    COLOR["fuchsia"] = "255,0,255"
    COLOR["olympic_blue"] = "0,142,204"
    COLOR["azure_blue"] = "0,128,255"
    COLOR["midnight_blue"] = "25,25,112"
    COLOR["light_sky_blue"] = "135,206,250"
    COLOR["light_steel_blue"] = "176,196,222"
    COLOR["forest_green"] = "34,139,34"
    COLOR["menu_gray"] = "30,30,30"
    COLOR["menu_white"] = "200,200,200"
    COLOR["selection_gray"] = "50,50,50"
    COLOR["light_pink"] = "255,182,193"
    COLOR["dark_green"] = "0,100,0"
}

### Buffer functions ###

function console_write(str, x, y, front, back,   back_rgb, front_rgb, i, a, char) {

    # Get front color RGB values
    if (front && index(front, ",")) {
        split(front,a,",")
    } else if (front) {
        split(COLOR[front],a,",")
    } else {
        split(COLOR["white"],a,",")
    }
    front_rgb = sprintf("\033[38;2;%s;%s;%sm", a[1], a[2], a[3])

    # Get back color RGB values
    if (back && index(back, ",")) {
        split(back,a,",")
    } else if (back) {
        split(COLOR[back],a,",")
    } else {
        split(COLOR["black"],a,",")
    }
    back_rgb = sprintf("\033[48;2;%s;%s;%sm", a[1], a[2], a[3])
    
    # Write string & colors to buffers
    for (i=1; i <= min(screen_width, length(str));i++) {
        char = substr(str, i, 1)
        if (i==1) {
            char = char
        }
        CHAR_BUFFER[x+i-1][y] = char
        FRONT_COLOR_BUFFER[x+i-1][y] = front_rgb
        BACK_COLOR_BUFFER[x+i-1][y] = back_rgb
    } 
}


function set_character(char, x, y) {
    CHAR_BUFFER[x][y] = char
}


function get_character(x, y) {
    return CHAR_BUFFER[x][y]
}


function set_front_color(front, x, y) {
    FRONT_COLOR_BUFFER[x][y] = front
}


function get_front_color(x, y) {
    return FRONT_COLOR_BUFFER[x][y]
}


function set_back_color(back, x, y) {
    BACK_COLOR_BUFFER[x][y] = back
}


function get_back_color(x, y) {
    return BACK_COLOR_BUFFER[x][y]
}


function clear_buffer(   x, y) {
    for (y=0; y<screen_height;y++) {
		for (x=0;x<screen_width;x++) {
            console_write(" ", x, y, "white", "black")
        }
    }
}


function merge_buffer_layers(    x, y, front_color, back_color, char, cell) {
    for(y=0;y<screen_height;y++){
        for(x=0;x<screen_width;x++) {
            front_color = FRONT_COLOR_BUFFER[x][y]
            back_color = BACK_COLOR_BUFFER[x][y]
            char = CHAR_BUFFER[x][y]
            cell = front_color back_color char
            SCREEN_BUFFER[x][y] = cell    
        }
    }
}


function flip_buffer(   y, x, cell) {
	for (y=0; y<screen_height;y++) {
		for (x=0;x<screen_width;x++) {
            if (SCREEN_BUFFER[x][y] != CURRENT_SCREEN[x][y]) {
                cell = SCREEN_BUFFER[x][y]
		        putch(cell, x, y)
				CURRENT_SCREEN[x][y] = SCREEN_BUFFER[x][y]
			}
		}
	}
    reset_cursor()
}


### Direct console access functions ###

function putch(char, x, y) {
    printf "\033[%s;%sH%s", y+1, x, char
}


function cls() {
	printf "\033[2J"
}


function move_cursor(x, y) {
    printf "\033[%s;%sH", y+1, x
}


function revert_cursor(columns) {
    printf "\033[%sD", columns
}


function set_foreground_color(r, g, b) {
    printf "\033[38;2;%s;%s;%sm", r, g, b
}


function set_background_color(r, g, b) {
    printf "\033[48;2;%s;%s;%sm", r, g, b
}


function show_cursor() {
    printf "\033[?25h"
}



function hide_cursor() {
    printf "\033[?25l"
}


function reset_cursor() {
    printf "\033[H" 
}


function print_at_row(line, row) {
    move_cursor(1, row)
	print(line)
}


function get_input(echo,   arrow, key) {
    # Turn off console echo if requested
    if (echo == 1) {
        system("stty -echo") 
    }

    # Clear stdin
    system("bash -c 'read -n 1000 -t 0.0001 -s'") 

    # Read up to three characters (arrow keys are 3)
    cmd = "bash -c 'if read -n 1 key; then read -n 2 -t 0.00005 char; fi; echo $key$char'"
    cmd | getline key
    close(cmd)

    return key
}

### Other functions ###

function fade_in(char,   i, step) {
    step = 1
    for (i=0;i<=255;i+=step) {
        set_foreground_color(i, i, i)
        printf char
        if (i <= 255-step) {
            revert_cursor(1)
        }
    }
}