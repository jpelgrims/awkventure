# Game functions library
# Requires stdlib.awk

function store_entity(id, pos_x, pos_y) {
	entities[0, id] = id
	entities[0, x] = pos_x
	entities[0, y] = pos_y
}

function print_at_row(line, row) {
	printf "\033[%s;0H", row
	printf line
}

function render_banner(banner_lines, subtext, screen_width, screen_height) {
	system("clear")

	banner_height = array_length(banner_lines)
	space_left = screen_height-(banner_height) # +2 for the subtext
	space = int(space_left/2)
	for (y=0;y<=space;y++) {
		printf "\n"
	}
	for (y=0;y<=banner_height;y++) {
		center(banner_lines[y], screen_width)
	}
	printf "\n"
	center(subtext, screen_width)
	for (y=0;y<=space;y++) {
		printf "\n"
	}
}

function get_input(   input) {
	system("stty -echo") # turn off echo
	cmd = "bash -c 'read -n 1 input; echo $input'"
	cmd | getline input
	close(cmd)
	return input
}

function handle_input(   key) {
	key = get_input()
	if (key == KEY["UP"]) {
		entities[0, y]--
	}  else if (key == KEY["DOWN"]) {
		entities[0, y]++
	} else if (key == KEY["LEFT"]) {
		entities[0, x]--
	} else if (key == KEY["RIGHT"]) {
		entities[0, x]++
	} else if (key == KEY["ESCAPE"]) {
		cls()
		printf "\033[H"
		printf "\033[?25h"
		system("stty echo")
		exit 0
	}
}

# Need to make buffer render
# first draw to buffer
# then dump buffer to screen (only changed chars)

function render() {
	# Render world
	for (y=0; y<=screen_height;y++) {
		for (x=0;x<=screen_width;x++) {
			SCREEN_BUFFER[x, y]="."
		}
	}

	SCREEN_BUFFER[entities[0, x], entities[0, y]] = "@"

	# Render entity
	#putch("@", , )

}

# Line-based buffer
function render_buffer() {
	printf "\033[H" # cursor to upper left

	for (y=0; y<=screen_height;y++) {
		for (x=0;x<=screen_width;x++) {
			if (CURRENT_SCREEN[x, y] != SCREEN_BUFFER[x, y]) { # only print if screen line changed
				printf "\033[%s;%sH%c", y, x, SCREEN_BUFFER[x, y]
				CURRENT_SCREEN[x, y] = SCREEN_BUFFER[x, y]
			}
		}
	}
}

function update() {

}