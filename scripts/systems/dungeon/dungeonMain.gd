extends Node2D

@onready var room_container: Node2D = $RoomContainer


func _ready() -> void:
	load_room(DungeonManager.start_dungeon())


func load_room(room_path: String, entrance_direction: String = "south") -> void:
	for child in room_container.get_children():
		child.queue_free()

	var room_scene: PackedScene = load(room_path)
	var room_instance = room_scene.instantiate()
	room_container.add_child(room_instance)

	var player = get_tree().get_first_node_in_group("player")
	var spawn_name := entrance_direction.capitalize() + "Spawn"
	var spawn_point = room_instance.get_node_or_null("PlayerSpawnPoints/" + spawn_name)

	print("Entrance direction: ", entrance_direction)
	print("Spawn name: ", spawn_name)
	print("Player found: ", player)
	print("Spawn found: ", spawn_point)

	if player != null and spawn_point != null:
		player.global_position = spawn_point.global_position

func load_next_room(exit_direction: String) -> void:
	var entrance_direction := get_opposite_direction(exit_direction)
	var next_room_path := DungeonManager.go_to_next_floor(exit_direction)

	load_room(next_room_path, entrance_direction)

func get_opposite_direction(direction: String) -> String:
	match direction:
		"north": return "south"
		"south": return "north"
		"east": return "west"
		"west": return "east"
	return "south"
