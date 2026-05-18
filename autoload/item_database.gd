extends Node

var items: Dictionary = {}

const ITEM_FOLDERS := [
	"res://assets/items/weapons",
	"res://assets/items/armor",
	"res://assets/items/consumables",
	"res://assets/items/resources",
	"res://assets/items/quest",
	"res://assets/items/misc"
]

func _ready() -> void:
	load_all_items()

func load_all_items() -> void:
	items.clear()

	for folder_path in ITEM_FOLDERS:
		load_items_from_folder(folder_path)

func load_items_from_folder(folder_path: String) -> void:
	var dir := DirAccess.open(folder_path)

	if dir == null:
		return

	dir.list_dir_begin()

	var file_name := dir.get_next()

	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var item := load(folder_path + "/" + file_name)

			if item is ItemData:
				items[item.id] = item

		file_name = dir.get_next()

	dir.list_dir_end()

func get_item(item_id: String) -> ItemData:
	return items.get(item_id, null)
