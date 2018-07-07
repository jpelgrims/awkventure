function create_world(terrain, width, height, fill_tile,    x, y) {
    terrain["width"] = width 
    terrain["height"] = height 

    for(x=0; x < width; x++) {
        for(y=0; y < height; y++) {
            terrain[x][y] = TILE_DATA[fill_tile]["char"]
        }
    }
}

function generate_random_walk_cave(terrain, width, height, x, y, length_of_walk,    i, t) {
    create_world(terrain, width, height, "wall")
    terrain[x][y] = TILE_DATA["ground"]["char"]

    for (i=0; i<length_of_walk; i++) {

        t = randint(1,4)

        if (t == 1 && (x+1 < width-2)) {
            x += 1
        } else if (t == 2 && (x-1) > 1) {
            x -= 1
        } else if (t == 3 && (y+1) < (height-2)) {
            y += 1
        } else if (t == 4 && (y-1) > 1) {
            y -= 1
        }

        terrain[x][y] = TILE_DATA["ground"]["char"]
        
    }
}

function generate_border(terrain, width, height) {
    for(y=0;y<height;y++) {
        if (y == 0 || y == height-1) {
            for (x=0;x<width;x++) {
                terrain[x][y] = TILE_DATA["wall"]["char"]
            }
        } else {
            terrain[0][y] = TILE_DATA["wall"]["char"]
            terrain[width-1][y] = TILE_DATA["wall"]["char"]
        }
    }
}

function create_tunnel(terrain, direction, p1, p2, p) {
    for(i=min(p1,p2); i < max(p1, p2)+1; i++) {
        if (direction == "horizontal") {
            terrain[i][p] = terrain[x][y] = TILE_DATA["ground"]["char"]
        } else if (direction == "vertical") {
            terrain[p][i] = terrain[x][y] = TILE_DATA["ground"]["char"]
        }
    }
}

function create_room(terrain, x_pos, y_pos, width, height,   x, y) {
    for (x = x_pos+1; x < x_pos + width; x++) {
        for (y = y_pos+1; y < y_pos + height; y++) {
            terrain[x][y] = TILE_DATA["ground"]["char"]
        }
    }
}

function generate_dungeon(terrain, width, height, max_rooms, room_min_size, room_max_size,    i, x, w, h, rooms) {
    create_world(terrain, width, height, "wall")

    num_rooms = 0

    for (r=0; r < max_rooms; r++) {
        w = randint(room_min_size, room_max_size)
        h = randint(room_min_size, room_max_size)

        x = randint(0, width - w - 1)
        y = randint(0, height - h - 1)

        collision = 0

        for (i=0;i<num_rooms;i++) {
            
            x2 = rooms[i]["x"]
            y2 = rooms[i]["y"]
            w2 = rooms[i]["width"]
            h2 = rooms[i]["height"]

            # Collision
            if (x <= (x2+w2) && (x+w) >= x2 && y <= y2+h2 && y+h >= y2) {
                collision = 1
                break
            }
        }

        if (!collision) {
            create_room(terrain, x, y, w, h)

            center_x = int((x+ (x+w)) /2 )
            center_y = int((y+ (y+h)) /2 )

            if (num_rooms == 0) {
                ENTITIES[0]["x"] = center_x
                ENTITIES[0]["y"] = center_y
            } else {

                prev_x = rooms[num_rooms-1]["center_x"]
                prev_y = rooms[num_rooms-1]["center_y"]

                if (randint(0, 1)) {
                    create_tunnel(terrain, "horizontal", prev_x, center_x, prev_y)
                    create_tunnel(terrain, "vertical", prev_y, center_y, center_x)
                } else {
                    create_tunnel(terrain, "vertical", prev_y, center_y, prev_x)
                    create_tunnel(terrain, "horizontal", prev_x, center_x, center_y)
                }
            }

            rooms[num_rooms]["center_x"] = center_x
            rooms[num_rooms]["center_y"] = center_y
            rooms[num_rooms]["width"] = width
            rooms[num_rooms]["height"] = height
            rooms[num_rooms]["x"] = x
            rooms[num_rooms]["y"] = y
            num_rooms += 1
        }
    }
}