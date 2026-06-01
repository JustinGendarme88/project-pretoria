extends Node

var buildings: Dictionary = {}


func _ready() -> void:
	register_building(preload("res://data/buildings/town_hall.tres"))
	# Plus tard :
	# register_building(preload("res://data/buildings/blacksmith.tres"))
	# register_building(preload("res://data/buildings/barracks.tres"))


func register_building(building_data: BuildingData) -> void:
	if building_data == null:
		return

	if building_data.id == "":
		push_warning("BuildingData has empty id.")
		return

	buildings[building_data.id] = building_data


func get_building(building_id: String) -> BuildingData:
	return buildings.get(building_id, null)


func has_building(building_id: String) -> bool:
	return buildings.has(building_id)
