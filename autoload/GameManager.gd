extends Node

var ui_open: bool = false
var gold: int = 0

var test_sword: ItemData = preload("res://data/item/gear/iron_sword.tres")

var inventory: Array[ItemData] = []

func _ready() -> void:
	inventory.append(test_sword)

func add_gold(amount: int) -> void:
	gold += max(amount, 0)

func remove_gold(amount: int) -> bool:
	if gold < amount:
		return false
	
	gold -= amount
	return true

func has_gold(amount: int) -> bool:
	return gold >= amount

func set_gold(amount: int) -> void:
	gold = max(amount, 0)
