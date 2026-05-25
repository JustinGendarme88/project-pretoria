extends Node

signal saves_changed

const SAVE_DIR := "user://saves/"
const MANUAL_SLOT_COUNT := 10
const AUTO_SLOT_COUNT := 3

var current_autosave_slot := 1


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func can_save() -> bool:
	if GameManager.player == null:
		return false

	if not "current_state" in GameManager.player:
		return true

	match GameManager.player.current_state:
		GameManager.player.PlayerState.NORMAL:
			return true
		GameManager.player.PlayerState.MENU:
			return true
		_:
			return false


func is_valid_slot(slot: int, is_auto_save: bool = false) -> bool:
	if is_auto_save:
		return slot >= 1 and slot <= AUTO_SLOT_COUNT

	return slot >= 1 and slot <= MANUAL_SLOT_COUNT


func get_player_save_data() -> Dictionary:
	if GameManager.player == null:
		return {
			"position_x": 0,
			"position_y": 0,
			"health": 0
		}

	return {
		"position_x": GameManager.player.global_position.x,
		"position_y": GameManager.player.global_position.y,
		"health": GameManager.player.health
	}


func get_manual_save_path(slot: int) -> String:
	return SAVE_DIR + "manual_%02d.save" % slot


func get_autosave_path(slot: int) -> String:
	return SAVE_DIR + "autosave_%02d.save" % slot


func save_game(slot: int, is_auto_save: bool = false) -> bool:
	if not is_valid_slot(slot, is_auto_save):
		push_warning("Invalid save slot: %d" % slot)
		return false

	if not is_auto_save and not can_save():
		push_warning("Cannot save right now.")
		return false

	var path := ""

	if is_auto_save:
		path = get_autosave_path(slot)
	else:
		path = get_manual_save_path(slot)

	var save_name := "Save Slot %d" % slot
	if is_auto_save:
		save_name = "Autosave %d" % slot

	var save_data := {
		"version": 1,
		"save_name": save_name,
		"timestamp": Time.get_datetime_string_from_system(),
		"main_scene": GameManager.main_scene_path,
		"current_world_scene": GameManager.current_world_scene_path,
		"player": get_player_save_data(),
		"flags": FlagManager.flags,
		"inventory": InventoryManager.get_save_data(),
		"quests": QuestManager.get_save_data()
	}

	var file := FileAccess.open(path, FileAccess.WRITE)

	if file == null:
		push_error("Failed to open save file: " + path)
		return false

	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()

	print("Game saved: ", path)
	saves_changed.emit()
	return true


func load_game(slot: int, is_auto_save: bool = false) -> bool:
	if not is_valid_slot(slot, is_auto_save):
		push_warning("Invalid save slot: %d" % slot)
		return false

	var path := ""

	if is_auto_save:
		path = get_autosave_path(slot)
	else:
		path = get_manual_save_path(slot)

	if not FileAccess.file_exists(path):
		print("No save found: ", path)
		return false

	var file := FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("Failed to open save file: " + path)
		return false

	var content := file.get_as_text()
	file.close()

	var json := JSON.new()
	var result := json.parse(content)

	if result != OK:
		print("Failed to parse save file.")
		return false

	var save_data: Dictionary = json.data

	await _apply_save_data(save_data)
	return true


func _apply_save_data(save_data: Dictionary) -> void:
	if save_data.has("flags"):
		FlagManager.flags = save_data["flags"]

	if save_data.has("inventory"):
		InventoryManager.load_save_data(save_data["inventory"])

	if save_data.has("quests"):
		QuestManager.load_save_data(save_data["quests"])

	var main_scene_path: String = save_data.get("main_scene", GameManager.main_scene_path)
	var world_scene_path: String = save_data.get("current_world_scene", "")

	if main_scene_path == "":
		return

	GameManager.player = null
	GameManager.world_container = null
	GameManager.current_world = null
	GameManager.is_changing_zone = false
	GameManager.ui_open = false
	get_tree().paused = false

	await get_tree().change_scene_to_file(main_scene_path)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	if GameManager.world_container == null:
		push_warning("WorldContainer was not registered after loading main scene.")
		return

	if world_scene_path != "":
		await GameManager.change_zone(world_scene_path, "default")

	await get_tree().process_frame
	await get_tree().process_frame

	if GameManager.player != null and save_data.has("player"):
		var player_data: Dictionary = save_data["player"]

		GameManager.player.global_position = Vector2(
			player_data.get("position_x", 0),
			player_data.get("position_y", 0)
		)

		GameManager.player.health = player_data.get(
			"health",
			GameManager.player.max_health
		)

		if "current_state" in GameManager.player:
			GameManager.player.current_state = GameManager.player.PlayerState.NORMAL

	GameManager.ui_open = false
	get_tree().paused = false


func delete_save(slot: int, is_auto_save: bool = false) -> void:
	if not is_valid_slot(slot, is_auto_save):
		push_warning("Invalid save slot: %d" % slot)
		return

	var path := ""

	if is_auto_save:
		path = get_autosave_path(slot)
	else:
		path = get_manual_save_path(slot)

	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		saves_changed.emit()


func get_save_info(slot: int, is_auto_save: bool = false) -> Dictionary:
	if not is_valid_slot(slot, is_auto_save):
		return {
			"exists": false
		}

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

	if file == null:
		return {
			"exists": false
		}

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
		"scene": data.get("current_world_scene", data.get("current_scene", ""))
	}


func create_autosave() -> bool:
	var success := await save_game(current_autosave_slot, true)

	if success:
		current_autosave_slot += 1

		if current_autosave_slot > AUTO_SLOT_COUNT:
			current_autosave_slot = 1

	return success
