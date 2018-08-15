function menu_loop() {
	draw_banner_faded()
	cursor_pos = 1
	nr_of_menu_items = 2
	sleep(1)
	set_foreground_color(255, 255, 255)
	draw_background()
	while (1) {

		if (savefile()) {
			putch("Continue game", 35, 17)
		} else {
			putch("New game", 35, 17)
		}
		putch("Exit", 35, 18)
		
		putch("Press (E) to choose", 35, 20)

		for(y=16;y<17+nr_of_menu_items;y++) {
			putch(" ", 33, y+cursor_pos-1)
		}

		putch(">", 33, 17+cursor_pos-1)

		key = get_input(0)

		if (key == KEY["UP"] || match(key, /\033\[A/)) {
			if (cursor_pos > 1) {
				cursor_pos-- 
			}
		} else if (key == KEY["DOWN"] || match(key, /\033\[B/)) {
			if (cursor_pos < nr_of_menu_items) {
				cursor_pos++ 
			}
		} else if (match(key,  /e|E/)) {
			if (cursor_pos == 1) {
				singleplayer_loop()
			} else if (cursor_pos == 2) {
				shutdown()
			}
		}  else if (match(key,  /^\033$/)) {
			shutdown()
		}
		sleep(0.01)
	}
}


function play_intro() {
	# Show game title
	subtext_nr = randint(0, array_length(subtexts))

	cls()

	# Show game story
	for (i in story) {
		move_cursor(4, (screen_height-8)/2+i)
		split(story[i], words," ")
		for (w in words) {

			for (o=1;o<=length(words[w]);o++) {
				char = substr(words[w], o, 1)
				if (char != ".") {
					fade_in(char)
					sleep(0.03)
				} else {
					printf char
					sleep(1.5)
				}
				
			}
			sleep(0.05)
			printf " "
		}
		
	}
	show_cursor()
	printf "\n\n   Press any key to start"
	get_input()
	hide_cursor()
}

function draw_banner(ypos) {
	for(y=0;y<length(banner);y++) {
		move_cursor(0, (screen_height-12-ypos)/2+y)
		center(banner[y], screen_width)
	}
}

function draw_background(y, i) {
	for(y=0;y<6;y++) {
		cls()
		for(i=0;i<length(banner);i++) {
			move_cursor(12, 6-y+i)
			printf banner[i]
		}
		sleep(0.2)
	}

	for(y=0;y<length(background);y++){
		move_cursor(0, 8+y)
		printf background[y]
	}
}

function draw_banner_faded() {
	for(i=0;i<=200;i+=5) {
		set_foreground_color(i, i, i)
		draw_banner()
		sleep(0.05)
	}
}