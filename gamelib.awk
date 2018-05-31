function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s) { return rtrim(ltrim(s)); }

function array_length(array,    alength) {
	alength = 0
	for (item in array) {
		alength++
	} 
	return alength
}

function randint(min, max) {
	return int(((rand()*100) % (max -  min + 1)) + min)
}

function center(line, screen_width) {
	space_left = screen_width - length(line)
	side_space = int(space_left/2)
	for (i=0; i <= side_space; i++) {
		newline = newline " "
	}
	newline = newline line
	for (i=0; i <= side_space; i++) {
		newline = newline " "
	}
	return newline
}

function print_at_row(line, row) {
	printf "\033[%s;0H", row
	printf line
}

function print_centered(line, screen_width) {
	space_left = screen_width - length(line)
	side_space = int(space_left/2)

	for (i=0; i <= side_space; i++) {
		printf " "
	}
	printf line
	for (i=0; i <= side_space; i++) {
		printf " "
	}
	printf "\n"

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
		print_centered(banner_lines[y], screen_width)
	}
	printf "\n"
	print_centered(subtext, screen_width)
	for (y=0;y<=space;y++) {
		printf "\n"
	}
}

function get_input() {
	system("stty -echo") # turn off echo
	cmd = "bash -c 'read -n 1 input; echo $input'"
	cmd | getline input
	system("stty echo") # turn on echo
	return input
}

function handle_input(input) {
	key = get_input()
	print key
}

function clear_screen() {
	printf "\033[H" # Move the cursor to the upper-left corner of the screen
}

function render() {
	system("stty echo") # echo on
	printf "\033[H" # cursor to upper left
	for (i=0; i<=screen_width*screen_height;i++) {
		printf "."
		if (i%screen_width == 0) {
			printf "\n"
		}	
	}
	system("stty -echo") # echo off
}

function update() {

}