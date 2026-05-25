extends Control

@export var save_slot_entry_scene: PackedScene
@export var hide_on_start: bool = true
@export var show_close_button: bool = true
@export var pause_game_when_opened: bool = true

@onready var auto_slots_container: VBoxContainer = $Panel/MarginContainer/ScrollContainer/VBoxContainer/AutoSlotsContainer
@onready var manual_slots_container: VBoxContainer = $Panel/MarginContainer/ScrollContainer/VBoxContainer/ManualSlotsContainer
@onready var close_button: Button = $Panel/MarginContainer/ScrollContainer/VBoxContainer/CloseButton


func _ready() -> void:
	visible = not hide_on_start
	process_mode = Node.PROCESS_MODE_ALWAYS

	close_button.visible = show_close_button
	close_button.pressed.connect(close_menu)

	if not SaveManager.saves_changed.is_connected(_refresh_slots):
		SaveManager.saves_changed.connect(_refresh_slots)

	_refresh_slots()


func open_menu() -> void:
	visible = true
	GameManager.ui_open = true

	if GameManager.player != null and "current_state" in GameManager.player:
		GameManager.player.current_state = GameManager.player.PlayerState.MENU

	if pause_game_when_opened:
		get_tree().paused = true

	_refresh_slots()


func close_menu() -> void:
	visible = false
	GameManager.ui_open = false

	if GameManager.player != null and "current_state" in GameManager.player:
		GameManager.player.current_state = GameManager.player.PlayerState.NORMAL

	if pause_game_when_opened:
		get_tree().paused = false


func _refresh_slots() -> void:
	_clear_container(auto_slots_container)
	_clear_container(manual_slots_container)

	for i in range(1, SaveManager.AUTO_SLOT_COUNT + 1):
		_create_slot_entry(i, true)

	for i in range(1, SaveManager.MANUAL_SLOT_COUNT + 1):
		_create_slot_entry(i, false)


func _create_slot_entry(slot: int, is_auto_save: bool) -> void:
	var entry = save_slot_entry_scene.instantiate()

	if is_auto_save:
		auto_slots_container.add_child(entry)
	else:
		manual_slots_container.add_child(entry)

	var save_info := SaveManager.get_save_info(slot, is_auto_save)
	entry.setup(slot, is_auto_save, save_info)

	entry.save_requested.connect(_on_save_requested)
	entry.load_requested.connect(_on_load_requested)
	entry.delete_requested.connect(_on_delete_requested)


func _clear_container(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()


func _on_save_requested(slot: int) -> void:
	var success := await SaveManager.save_game(slot, false)

	if success:
		_refresh_slots()


func _on_load_requested(slot: int, is_auto_save: bool) -> void:
	GameManager.ui_open = false

	if GameManager.player != null and "current_state" in GameManager.player:
		GameManager.player.current_state = GameManager.player.PlayerState.NORMAL

	if pause_game_when_opened:
		get_tree().paused = false

	visible = false

	var success := await SaveManager.load_game(slot, is_auto_save)

	if not success:
		print("Load failed.")


func _on_delete_requested(slot: int, is_auto_save: bool = false) -> void:
	SaveManager.delete_save(slot, is_auto_save)
	_refresh_slots()
