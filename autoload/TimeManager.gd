extends Node

signal day_advanced(day: int)

var current_day: int = 1


func advance_day() -> void:
	current_day += 1

	print("Day:", current_day)

	day_advanced.emit(current_day)


func get_save_data() -> Dictionary:
	return {
		"current_day": current_day
	}


func load_save_data(data: Dictionary) -> void:
	current_day = data.get("current_day", 1)
