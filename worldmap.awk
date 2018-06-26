function get_room_dimensions(x, y, room_data) {
	left_ray = ray_cast("room", "LEFT", x, y)
	right_ray = ray_cast("room", "RIGHT", x, y)
	up_ray = ray_cast("room", "UP", x, y)
	down_ray = ray_cast("room", "DOWN", x, y)

	room_data["x"] = x-left_ray
	room_data["y"] = y-up_ray
	room_data["width"] = left_ray + right_ray + 1
	room_data["height"] = up_ray + down_ray + 1
}

function is_corridor(x, y) {
	return (is_blocked(x-1, y) && is_blocked(x+1, y)) ||
			(is_blocked(x, y-1) && is_blocked(x, y+1))
}