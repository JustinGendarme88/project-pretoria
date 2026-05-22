extends Node

signal flag_changed(flag_name: String, value)

var flags: Dictionary = {}


func has_flag(flag_name: String) -> bool:
	return flags.has(flag_name)


func get_flag(flag_name: String, default_value = false):
	return flags.get(flag_name, default_value)


func set_flag(flag_name: String, value) -> void:
	if flag_name.is_empty():
		return

	flags[flag_name] = value

	flag_changed.emit(flag_name, value)


func remove_flag(flag_name: String) -> void:
	if flags.has(flag_name):
		flags.erase(flag_name)

		flag_changed.emit(flag_name, null)


func clear_flags() -> void:
	flags.clear()


func get_save_data() -> Dictionary:
	return flags.duplicate(true)


func load_save_data(data: Dictionary) -> void:
	flags = data.duplicate(true)
