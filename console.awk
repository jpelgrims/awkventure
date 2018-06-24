BEGIN {
    COLOR["green"] = "0,255,0"
    COLOR["blue"] = "0,0,255"
    COLOR["red"] = "255,0,0"
    COLOR["white"] = "255,255,255"
    COLOR["black"] = "0,0,0"
    COLOR["grey"] = "169,169,169"
    COLOR["brown"] = "165,42,42"
    COLOR["yellow"] = "255,255,0"
}

function setch(char, x, y) {
    SCREEN_BUFFER[x][y] = char
}

function setch_color(char, x, y, front, back,    back_rgb, front_rgb) {
    split(COLOR[front],a,",")
    front_rgb = sprintf("\033[38;2;%s;%s;%sm", a[1], a[2], a[3])
    split(COLOR[back],a,",")
    back_rgb = sprintf("\033[48;2;%s;%s;%sm", a[1], a[2], a[3])
    SCREEN_BUFFER[x][y] = front_rgb back_rgb char
    #printf front_rgb
    #print("test " back " " COLOR[back] " " a[1] " " a[2] " " a[3] " " front_rgb back_rgb "t")
    #sleep(1)
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

# Moves cursor one back
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

# Line-based buffer
function flip_buffer(   y, x) {
	for (y=0; y<screen_height;y++) {
		for (x=0;x<screen_width;x++) {
            if (CURRENT_SCREEN[x][y] != SCREEN_BUFFER[x][y]) { # only print if screen line changed
		        putch(SCREEN_BUFFER[x][y], x, y)
				CURRENT_SCREEN[x][y] = SCREEN_BUFFER[x][y]
			}
		}
	}
    reset_cursor()
}