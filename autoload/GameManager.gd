extends Node

var player: Node2D = null

var ui_open: bool = false

var test_sword: ItemData = preload("res://data/item/gear/iron_sword.tres")

var inventory: Array[ItemData] = []
var gold: int = 0

var target_spawn_id: String = "default"
var is_changing_zone := false

func _ready() -> void:
	inventory.append(test_sword)

func add_gold(amount: int) -> void:
	gold += max(amount, 0)

func remove_gold(amount: int) -> bool:
	if gold < amount:
		return false
	
	gold -= amount
	return true

func has_gold(amount: int) -> bool:
	return gold >= amount

func set_gold(amount: int) -> void:
	gold = max(amount, 0)

func register_player(player_node: Node2D) -> void:
	player = player_node

func change_zone(scene_path: String, spawn_id: String = "default") -> void:
	if is_changing_zone:
		return

	is_changing_zone = true
	target_spawn_id = spawn_id

	player = null

	await get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await get_tree().process_frame

	_place_player_at_spawn()

	is_changing_zone = false


func _place_player_at_spawn() -> void:
	if player == null:
		push_warning("No player registered after scene change.")
		return

	var spawn_points := get_tree().get_nodes_in_group("spawn_points")

	for spawn_point in spawn_points:
		if spawn_point is SpawnPoint and spawn_point.spawn_id == target_spawn_id:
			player.global_position = spawn_point.global_position
			return

	push_warning("Spawn point not found: " + target_spawn_id)
