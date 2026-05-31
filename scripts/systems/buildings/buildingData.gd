extends Resource
class_name BuildingData

@export var id: String
@export var display_name: String

@export var level_1_scene: PackedScene
@export var level_2_scene: PackedScene
@export var level_3_scene: PackedScene

@export var level_1_cost: Dictionary = {}
@export var level_2_cost: Dictionary = {}
@export var level_3_cost: Dictionary = {}

@export var level_1_days: int = 1
@export var level_2_days: int = 2
@export var level_3_days: int = 3

func get_scene_for_level(level: int) -> PackedScene:
	match level:
		1:
			return level_1_scene
		2:
			return level_2_scene
		3:
			return level_3_scene
		_:
			return null


func get_cost_for_next_level(current_level: int) -> Dictionary:
	match current_level:
		0:
			return level_1_cost
		1:
			return level_2_cost
		2:
			return level_3_cost
		_:
			return {}

func get_days_for_next_level(current_level: int) -> int:
	match current_level:
		0:
			return level_1_days
		1:
			return level_2_days
		2:
			return level_3_days
		_:
			return 0
