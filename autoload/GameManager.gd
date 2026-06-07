extends Node
var player: Node2D = null
var world_container: Node2D = null
var current_world: Node = null

var main_scene_path := "res://scenes/systems/Main.tscn"
var current_world_scene_path := ""

var target_spawn_id: String = "default"
var is_changing_zone := false

var ui_open: bool = false

var test_sword: ItemData = preload("res://data/item/gear/iron_sword.tres")

var inventory: Array[ItemData] = []
var gold: int = 0

var transition_fade: CanvasLayer = null
var location_banner: CanvasLayer = null

var is_time_transition := false
var time_transition: CanvasLayer = null

func _ready() -> void:
	inventory.append(test_sword)

func register_time_transition(node: CanvasLayer) -> void:
	time_transition = node
	
func register_location_banner(banner_node: CanvasLayer) -> void:
	location_banner = banner_node

func register_transition_fade(fade_node: CanvasLayer) -> void:
	transition_fade = fade_node

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

func register_world_container(container: Node) -> void:
	world_container = container
	if container.get_child_count() > 0:
		current_world = container.get_child(0)

func change_zone(scene_path: String, spawn_id: String = "default") -> void:
	if is_changing_zone:
		return

	if world_container == null:
		push_warning("No WorldContainer registered.")
		return

	is_changing_zone = true
	target_spawn_id = spawn_id

	if transition_fade != null:
		await transition_fade.fade_out(0.8)
		await get_tree().create_timer(0.2).timeout

	if current_world != null:
		current_world.queue_free()
		current_world = null

	var packed_scene := load(scene_path) as PackedScene
	if packed_scene == null:
		push_warning("Could not load world scene: " + scene_path)
		is_changing_zone = false
		return

	current_world_scene_path = scene_path

	var new_world := packed_scene.instantiate()
	world_container.add_child(new_world)
	current_world = new_world

	await get_tree().process_frame

	_place_player_at_spawn()

	if player != null and player.has_method("_apply_camera_limits"):
		player._apply_camera_limits()

	if transition_fade != null:
		await get_tree().create_timer(0.2).timeout
		await transition_fade.fade_in(0.8)

	is_changing_zone = false

	if location_banner != null and current_world != null:
		if "show_location_banner" in current_world and current_world.show_location_banner:
			if "location_name" in current_world:
				location_banner.show_location(current_world.location_name)

func _place_player_at_spawn() -> void:
	if player == null:
		push_warning("No player registered.")
		return

	var spawn_points := get_tree().get_nodes_in_group("spawn_points")

	for spawn_point in spawn_points:
		if spawn_point is SpawnPoint and spawn_point.spawn_id == target_spawn_id:
			player.global_position = spawn_point.global_position
			return

	push_warning("Spawn point not found: " + target_spawn_id)
