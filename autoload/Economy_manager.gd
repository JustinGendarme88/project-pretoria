extends Node

signal gold_changed(new_amount: int)

var gold: int = 0

var last_sold_items: Array[String] = []
const MAX_SOLD_HISTORY := 10


func add_gold(amount: int) -> void:
	if amount <= 0:
		return
	
	gold += amount
	gold_changed.emit(gold)


func remove_gold(amount: int) -> bool:
	if amount <= 0:
		return true
	
	if gold < amount:
		return false
	
	gold -= amount
	gold_changed.emit(gold)
	return true


func can_afford(amount: int) -> bool:
	return gold >= amount


func register_sold_item(item_id: String) -> void:
	last_sold_items.append(item_id)
	
	if last_sold_items.size() > MAX_SOLD_HISTORY:
		last_sold_items.pop_front()


func get_recent_sales_count(item_id: String) -> int:
	var count := 0
	
	for sold_id in last_sold_items:
		if sold_id == item_id:
			count += 1
	
	return count


func get_sell_multiplier(item_id: String) -> float:
	var count := get_recent_sales_count(item_id)
	
	if count >= 10:
		return 0.25
	elif count >= 7:
		return 0.5
	elif count >= 4:
		return 0.75
	
	return 1.0


func calculate_sell_price(item_id: String, base_sell_price: int) -> int:
	var multiplier := get_sell_multiplier(item_id)
	return max(1, int(base_sell_price * multiplier))
