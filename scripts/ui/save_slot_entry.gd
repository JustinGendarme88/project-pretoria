extends Control

signal save_requested(slot: int)
signal load_requested(slot: int, is_auto_save: bool)
signal delete_requested(slot: int)

@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton
@onready var delete_button: Button = %DeleteButton

@onready var slot_name_label: Label = %SlotNameLabel
@onready var timestamp_label: Label = %TimestampLabel
@onready var area_label: Label = %AreaLabel

var slot: int = -1
var is_auto_save: bool = false


func _ready() -> void:
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	delete_button.pressed.connect(_on_delete_pressed)


func setup(slot_number: int, auto_save: bool, save_info: Dictionary) -> void:
	slot = slot_number
	is_auto_save = auto_save

	if is_auto_save:
		save_button.visible = false
		delete_button.visible = false
		slot_name_label.text = "Auto Save %02d" % slot
	else:
		save_button.visible = true
		delete_button.visible = true
		slot_name_label.text = "Manual Save %02d" % slot

	if save_info.get("exists", false):
		timestamp_label.text = "Time: " + save_info.get("timestamp", "Unknown")
		area_label.text = "Area: " + save_info.get("area", "-")
		load_button.disabled = false
		delete_button.disabled = false
	else:
		timestamp_label.text = "Time: Empty"
		area_label.text = "Area: -"
		load_button.disabled = true
		delete_button.disabled = true


func _on_save_pressed() -> void:
	save_requested.emit(slot)


func _on_load_pressed() -> void:
	load_requested.emit(slot, is_auto_save)


func _on_delete_pressed() -> void:
	delete_requested.emit(slot)
