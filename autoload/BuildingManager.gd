extends Node

signal building_updated(building_id: String, new_level: int)
signal construction_started(building_id: String, target_level: int, days_remaining: int)
signal construction_completed(building_id: String, new_level: int)

var building_levels: Dictionary = {}

# Constructions en cours
# Exemple :
# {
#     "town_hall": {
#         "target_level": 1,
#         "days_remaining": 2
#     }
# }
var constructions: Dictionary = {}


func _ready() -> void:
	TimeManager.day_advanced.connect(_on_day_advanced)


func get_level(building_id: String) -> int:
	return building_levels.get(building_id, 0)


func is_max_level(building_data: BuildingData) -> bool:
	if building_data == null:
		return false

	return get_level(building_data.id) >= 3


func is_under_construction(building_id: String) -> bool:
	return constructions.has(building_id)


func get_days_remaining(building_id: String) -> int:
	if not constructions.has(building_id):
		return 0

	return constructions[building_id].get("days_remaining", 0)


func get_target_level(building_id: String) -> int:
	if not constructions.has(building_id):
		return get_level(building_id)

	return constructions[building_id].get("target_level", get_level(building_id))


func can_start_construction(building_data: BuildingData) -> bool:
	if building_data == null:
		return false

	if is_max_level(building_data):
		return false

	if is_under_construction(building_data.id):
		return false

	var current_level := get_level(building_data.id)
	var cost := building_data.get_cost_for_next_level(current_level)

	return InventoryManager.has_required_items(cost)


func start_construction(building_data: BuildingData) -> bool:
	if not can_start_construction(building_data):
		return false

	var current_level := get_level(building_data.id)
	var target_level := current_level + 1
	var days_remaining := building_data.get_days_for_next_level(current_level)
	var cost := building_data.get_cost_for_next_level(current_level)

	if not InventoryManager.remove_required_items(cost):
		return false

	constructions[building_data.id] = {
		"target_level": target_level,
		"days_remaining": days_remaining
	}

	construction_started.emit(
		building_data.id,
		target_level,
		days_remaining
	)

	return true


# Optionnel : garde cette fonction uniquement pour tests/dev tools.
# Elle améliore directement sans chantier.
func upgrade_building_instant(building_data: BuildingData) -> bool:
	if building_data == null:
		return false

	if is_max_level(building_data):
		return false

	if is_under_construction(building_data.id):
		return false

	var current_level := get_level(building_data.id)
	var new_level := current_level + 1

	building_levels[building_data.id] = new_level

	building_updated.emit(building_data.id, new_level)

	return true


func _on_day_advanced(day: int) -> void:
	var completed_buildings: Array[String] = []

	for building_id in constructions.keys():
		constructions[building_id]["days_remaining"] -= 1

		if constructions[building_id]["days_remaining"] <= 0:
			completed_buildings.append(building_id)

	for building_id in completed_buildings:
		var target_level: int = constructions[building_id]["target_level"]

		building_levels[building_id] = target_level
		constructions.erase(building_id)

		building_updated.emit(building_id, target_level)
		construction_completed.emit(building_id, target_level)


func get_building_status(building_data: BuildingData) -> String:
	if building_data == null:
		return "Unknown"

	if is_under_construction(building_data.id):
		return "Under Construction"

	var level := get_level(building_data.id)

	if level <= 0:
		return "Not Built"

	return "Level " + str(level)


func get_save_data() -> Dictionary:
	return {
		"building_levels": building_levels,
		"constructions": constructions
	}


func load_save_data(data: Dictionary) -> void:
	building_levels = data.get("building_levels", {}).duplicate()
	constructions = data.get("constructions", {}).duplicate()

	for building_id in building_levels.keys():
		building_updated.emit(
			building_id,
			building_levels[building_id]
		)
