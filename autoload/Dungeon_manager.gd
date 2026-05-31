extends Node

var current_floor: int = 1

var fire_normal_rooms: Array[String] = [
	"res://scenes/worlds/dungeon/fire/dungeon_fire_room_corner_ne.tscn",
	"res://scenes/worlds/dungeon/fire/dungeon_fire_room_corner_nw.tscn",
	"res://scenes/worlds/dungeon/fire/dungeon_fire_room_corner_se.tscn",
	"res://scenes/worlds/dungeon/fire/dungeon_fire_room_corner_sw.tscn",
	"res://scenes/worlds/dungeon/fire/dungeon_fire_room_corridor_horizontal.tscn",
	"res://scenes/worlds/dungeon/fire/dungeon_fire_room_corridor_vertical.tscn",
	"res://scenes/worlds/dungeon/fire/dungeon_fire_room_cross.tscn",
	"res://scenes/worlds/dungeon/fire/dungeon_fire_room_tshape_e.tscn",
	"res://scenes/worlds/dungeon/fire/dungeon_fire_room_tshape_n.tscn",
	"res://scenes/worlds/dungeon/fire/dungeon_fire_room_tshape_s.tscn",
	"res://scenes/worlds/dungeon/fire/dungeon_fire_room_tshape_w.tscn",
]

var room_exits := {
	"res://scenes/worlds/dungeon/fire/dungeon_fire_room_corner_ne.tscn": ["north", "east"],
	"res://scenes/worlds/dungeon/fire/dungeon_fire_room_corner_nw.tscn": ["north", "west"],
	"res://scenes/worlds/dungeon/fire/dungeon_fire_room_corner_se.tscn": ["south", "east"],
	"res://scenes/worlds/dungeon/fire/dungeon_fire_room_corner_sw.tscn": ["south", "west"],

	"res://scenes/worlds/dungeon/fire/dungeon_fire_room_corridor_horizontal.tscn": ["east", "west"],
	"res://scenes/worlds/dungeon/fire/dungeon_fire_room_corridor_vertical.tscn": ["north", "south"],

	"res://scenes/worlds/dungeon/fire/dungeon_fire_room_cross.tscn": ["north", "south", "east", "west"],

	"res://scenes/worlds/dungeon/fire/dungeon_fire_room_tshape_e.tscn": ["north", "south", "east"],
	"res://scenes/worlds/dungeon/fire/dungeon_fire_room_tshape_n.tscn": ["north", "east", "west"],
	"res://scenes/worlds/dungeon/fire/dungeon_fire_room_tshape_s.tscn": ["south", "east", "west"],
	"res://scenes/worlds/dungeon/fire/dungeon_fire_room_tshape_w.tscn": ["north", "south", "west"],
}


func start_dungeon() -> String:
	current_floor = 1
	return get_room_scene_for_current_floor()


func go_to_next_floor(exit_direction: String = "") -> String:
	current_floor += 1
	return get_room_scene_for_current_floor(exit_direction)


func get_room_scene_for_current_floor(exit_direction: String = "") -> String:
	if current_floor == 1:
		return "res://scenes/worlds/dungeon/fire/dungeon_fire_entrance_room.tscn"

	if current_floor == 25:
		return "res://scenes/worlds/dungeon/fire/dungeon_fire_boss_room.tscn"

	if current_floor % 10 == 0:
		return "res://scenes/worlds/dungeon/fire/dungeon_fire_safe_room.tscn"

	if exit_direction != "":
		return get_compatible_room(exit_direction)

	return fire_normal_rooms.pick_random()


func get_compatible_room(exit_direction: String) -> String:
	var required_entrance := get_opposite_direction(exit_direction)
	var valid_rooms: Array[String] = []

	for room_path in room_exits.keys():
		if required_entrance in room_exits[room_path]:
			valid_rooms.append(room_path)

	if valid_rooms.is_empty():
		push_error("No compatible room found for entrance: " + required_entrance)
		return fire_normal_rooms.pick_random()

	return valid_rooms.pick_random()


func get_opposite_direction(direction: String) -> String:
	match direction:
		"north": return "south"
		"south": return "north"
		"east": return "west"
		"west": return "east"

	return "south"
