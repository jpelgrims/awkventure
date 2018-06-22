function create_world(width, height, fill_tile,    terrain, x, y) {
    terrain["width"] = width 
    terrain["height"] = height 

    for(x=0; x < width; x++) {
        for(y=0; y < height; y++) {
            terrain[x][y] = TILE_DATA[fill_tile]["char"]
        }
    }
    return terrain

}

function generate_random_walk_cave(width, height, x, y, length_of_walk,    terrain, i) {
    terrain = create_world(width, height, "wall")

    for (i=0; i<length_of_path; i++) {

        t = randint(1,4)

        if (t == 1 && (x+1) > width-2) {
            x += 1
        } else if (t == 2 && (x-1) < 1) {
            x -= 1
        } else if (t == 3 && (y+1) > height-2) {
            y += 1
        } else if (t == 4 && (y-1) < 1) {
            y -= 1
        }

        terrain[x][y] = TILE_DATA["ground"]["char"]
    }

    return terrain
}