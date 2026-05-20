extends Node

var ui_open: bool = false

var test_sword: ItemData = preload("res://data/item/gear/iron_sword.tres")

var inventory: Array[ItemData] = []

func _ready() -> void:
	inventory.append(test_sword)
