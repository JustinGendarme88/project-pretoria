extends Resource
class_name ItemData

enum ItemType {
	MISC,
	CONSUMABLE,
	GEAR,
	QUEST,
	RESOURCE,
	MATERIAL
}

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

@export var id: String
@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D

@export var weight: float = 0.0
@export var rarity: Rarity = Rarity.COMMON

@export var item_type: ItemType = ItemType.MISC

@export var stackable: bool = false
@export var max_stack: int = 1

@export var buy_price: int = 0
@export var sell_price: int = 0

@export var sellable: bool = true
@export var quest_item: bool = false
