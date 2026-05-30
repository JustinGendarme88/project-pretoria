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

func start_dungeon() -> String:
	current_floor = 1
	return get_room_scene_for_current_floor()


func go_to_next_floor() -> String:
	current_floor += 1
	return get_room_scene_for_current_floor()


func get_room_scene_for_current_floor() -> String:
	if current_floor == 1:
		return "res://scenes/worlds/dungeon/fire/dungeon_fire_entrance_room.tscn"

	if current_floor == 25:
		return "res://scenes/worlds/dungeon/fire/dungeon_fire_boss_room.tscn"

	if current_floor % 10 == 0:
		return "res://scenes/worlds/dungeon/fire/dungeon_fire_safe_room.tscn"

	return fire_normal_rooms.pick_random()
