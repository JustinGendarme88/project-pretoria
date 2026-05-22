extends Node

const SAVE_DIR := "user://saves/"
const MANUAL_SLOT_COUNT := 10
const AUTO_SLOT_COUNT := 3

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func get_manual_save_path(slot: int) -> String:
	return SAVE_DIR + "manual_%02d.save" % slot


func get_autosave_path(slot: int) -> String:
	return SAVE_DIR + "autosave_%02d.save" % slot


func save_game(slot: int, is_auto_save: bool = false) -> void:
	var path := ""

	if is_auto_save:
		path = get_autosave_path(slot)
	else:
		path = get_manual_save_path(slot)

	var save_data := {
		"version": 1,
		"save_name": "Save Slot %d" % slot,
		"timestamp": Time.get_datetime_string_from_system(),
		"current_scene": get_tree().current_scene.scene_file_path,

		"player": {
			"position_x": GameManager.player.global_position.x,
			"position_y": GameManager.player.global_position.y,
			"health": GameManager.player.health
		},

		"flags": FlagManager.flags,
		"inventory": InventoryManager.get_save_data()
	}

	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()


func load_game(slot: int, is_auto_save: bool = false) -> void:
	var path := ""

	if is_auto_save:
		path = get_autosave_path(slot)
	else:
		path = get_manual_save_path(slot)

	if not FileAccess.file_exists(path):
		print("No save found: ", path)
		return

	var file := FileAccess.open(path, FileAccess.READ)
	var content := file.get_as_text()
	file.close()

	var json := JSON.new()
	var result := json.parse(content)

	if result != OK:
		print("Failed to parse save file.")
		return

	var save_data: Dictionary = json.data

	_apply_save_data(save_data)


func _apply_save_data(save_data: Dictionary) -> void:
	if save_data.has("flags"):
		FlagManager.flags = save_data["flags"]

	if save_data.has("inventory"):
		InventoryManager.load_save_data(save_data["inventory"])

	var scene_path: String = save_data.get("current_scene", "")

	if scene_path != "":
		await get_tree().change_scene_to_file(scene_path)
		await get_tree().process_frame

		if GameManager.player and save_data.has("player"):
			var player_data: Dictionary = save_data["player"]
			GameManager.player.global_position = Vector2(
				player_data.get("position_x", 0),
				player_data.get("position_y", 0)
			)
			GameManager.player.health = player_data.get("health", GameManager.player.max_health)


func delete_save(slot: int, is_auto_save: bool = false) -> void:
	var path := ""

	if is_auto_save:
		path = get_autosave_path(slot)
	else:
		path = get_manual_save_path(slot)

	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func get_save_info(slot: int, is_auto_save: bool = false) -> Dictionary:
	var path := ""

	if is_auto_save:
		path = get_autosave_path(slot)
	else:
		path = get_manual_save_path(slot)

	if not FileAccess.file_exists(path):
		return {
			"exists": false
		}

	var file := FileAccess.open(path, FileAccess.READ)
	var content := file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(content) != OK:
		return {
			"exists": false
		}

	var data: Dictionary = json.data

	return {
		"exists": true,
		"save_name": data.get("save_name", "Unknown Save"),
		"timestamp": data.get("timestamp", "Unknown Date"),
		"scene": data.get("current_scene", "")
	}
