BEGIN {
    COLOR["green"] = "0,255,0"
    COLOR["blue"] = "0,0,255"
    COLOR["red"] = "255,0,0"
    COLOR["white"] = "255,255,255"
    COLOR["black"] = "0,0,0"
    COLOR["grey"] = "169,169,169"
    COLOR["brown"] = "165,42,42"
    COLOR["yellow"] = "255,255,0"
    COLOR["dim_gray"] = "105,105,105"
}

function setch(char, x, y) {
    SCREEN_BUFFER[x][y] = char
}

function put_color(str, x, y, front, back, back_rgb, front_rgb, i) {
    if (front) {
        split(COLOR[front],a,",")
        front_rgb = sprintf("\033[38;2;%s;%s;%sm", a[1], a[2], a[3])
    } else {
        front_rgb = ""
    }
    
    if (back) {
        split(COLOR[back],a,",")
        back_rgb = sprintf("\033[48;2;%s;%s;%sm", a[1], a[2], a[3])
    } else {
        back_rgb = ""
    }
    
    for (i=1;i<= min(screen_width, length(str));i++) {
        char = substr(str, i, 1)
        if (i==1) {
            char = front_rgb back_rgb char
        }
        SCREEN_BUFFER[x+i-1][y] = char
    }

    
}

function setch_color(char, x, y, front, back,   back_rgb, front_rgb) {
    
    if (front) {
        split(COLOR[front],a,",")
        front_rgb = sprintf("\033[38;2;%s;%s;%sm", a[1], a[2], a[3])
    } else {
        front_rgb = ""
    }
    
    if (back) {
        split(COLOR[back],a,",")
        back_rgb = sprintf("\033[48;2;%s;%s;%sm", a[1], a[2], a[3])
    } else {
        back_rgb = ""
    }
    
    SCREEN_BUFFER[x][y] = front_rgb back_rgb char
}

function get_input(echo,   input) {
    if (echo == 1) {
        system("stty -echo") # turn off echo
    }
	cmd = "bash -c 'read -n 1 input; echo $input'"
	cmd | getline input
	close(cmd)
	return input
}

function fade_in(char,   i) {
    step = 1
    for (i=0;i<=255;i+=step) {
        set_foreground_color(i, i, i)
        printf char
        if (i <= 255-step) {
            revert_cursor(1)
        }
    }
}

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

function clear_buffer() {
    for (y=0; y<screen_height;y++) {
		for (x=0;x<screen_width;x++) {
            setch_color(" ", x, y, "black", "black")
        }
    }
}

function flip_buffer(   y, x) {
	for (y=0; y<screen_height;y++) {
		for (x=0;x<screen_width;x++) {
            if (SCREEN_BUFFER[x][y] != CURRENT_SCREEN[x][y]) {
		        putch(SCREEN_BUFFER[x][y], x, y)
				CURRENT_SCREEN[x][y] = SCREEN_BUFFER[x][y]
			}
		}
	}

    reset_cursor()
}