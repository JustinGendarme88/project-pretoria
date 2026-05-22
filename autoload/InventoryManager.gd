extends Node

signal inventory_updated
signal item_added(item)
signal item_removed(item)

var items: Array = []


func add_item(item) -> void:
	if item == null:
		return

	items.append(item)

	item_added.emit(item)
	inventory_updated.emit()


func remove_item(item) -> void:
	if item == null:
		return

	if items.has(item):
		items.erase(item)

		item_removed.emit(item)
		inventory_updated.emit()


func has_item(item_id: String) -> bool:
	for item in items:
		if item.id == item_id:
			return true

	return false


func get_item(item_id: String):
	for item in items:
		if item.id == item_id:
			return item

	return null


func clear_inventory() -> void:
	items.clear()

	inventory_updated.emit()


func get_all_items() -> Array:
	return items


func get_save_data() -> Array:
	var save_data: Array = []

	for item in items:
		save_data.append(item.id)

	return save_data


func load_save_data(data: Array) -> void:
	items.clear()

	for item_id in data:
		var item = ItemDatabase.get_item(item_id)

		if item != null:
			items.append(item)

	inventory_updated.emit()
