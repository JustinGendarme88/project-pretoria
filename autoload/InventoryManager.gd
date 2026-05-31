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

func get_item_count(item_id: String) -> int:
	var count := 0

	for item in items:
		if item.id == item_id:
			count += 1

	return count


func has_items(item_id: String, amount: int) -> bool:
	return get_item_count(item_id) >= amount


func remove_items(item_id: String, amount: int) -> bool:
	if not has_items(item_id, amount):
		return false

	var removed := 0

	for i in range(items.size() - 1, -1, -1):
		if items[i].id == item_id:
			var removed_item = items[i]
			items.remove_at(i)
			removed += 1

			item_removed.emit(removed_item)

			if removed >= amount:
				break

	inventory_updated.emit()
	return true


func has_required_items(cost: Dictionary) -> bool:
	for item_id in cost.keys():
		var amount: int = cost[item_id]

		if not has_items(item_id, amount):
			return false

	return true


func remove_required_items(cost: Dictionary) -> bool:
	if not has_required_items(cost):
		return false

	for item_id in cost.keys():
		var amount: int = cost[item_id]
		remove_items(item_id, amount)

	return true
