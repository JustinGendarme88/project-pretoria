extends Node2D

@export var building_data: BuildingData

var current_building: Node = null


func _ready() -> void:
	BuildingManager.building_updated.connect(_on_building_updated)
	refresh_building()


func _exit_tree() -> void:
	if BuildingManager.building_updated.is_connected(_on_building_updated):
		BuildingManager.building_updated.disconnect(_on_building_updated)


func _on_building_updated(building_id: String, new_level: int) -> void:
	if building_data == null:
		return

	if building_id != building_data.id:
		return

	refresh_building()


func refresh_building() -> void:
	if building_data == null:
		return

	if current_building != null:
		current_building.queue_free()
		current_building = null

	var level := BuildingManager.get_level(building_data.id)

	if level <= 0:
		return

	var scene := building_data.get_scene_for_level(level)

	if scene == null:
		return

	current_building = scene.instantiate()
	add_child(current_building)

	current_building.position = Vector2.ZERO
