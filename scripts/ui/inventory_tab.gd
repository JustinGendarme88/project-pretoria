extends Control

@export var inventory_slot_scene: PackedScene

@onready var gear_button: Button = $MarginContainer/HBoxContainer/CategoriesPanel/VBoxContainer/GearButton
@onready var consumables_button: Button = $MarginContainer/HBoxContainer/CategoriesPanel/VBoxContainer/ConsumablesButton
@onready var quest_button: Button = $MarginContainer/HBoxContainer/CategoriesPanel/VBoxContainer/QuestButton
@onready var materials_button: Button = $MarginContainer/HBoxContainer/CategoriesPanel/VBoxContainer/MaterialsButton

@onready var grid_container: GridContainer = $MarginContainer/HBoxContainer/ItemsPanel/ScrollContainer/GridContainer

@onready var item_name_label: Label = $MarginContainer/HBoxContainer/ItemDetailsPanel/MarginContainer/VBoxContainer/ItemNameLabel
@onready var item_description_label: Label = $MarginContainer/HBoxContainer/ItemDetailsPanel/MarginContainer/VBoxContainer/ItemDescriptionLabel
@onready var use_button: Button = $MarginContainer/HBoxContainer/ItemDetailsPanel/MarginContainer/VBoxContainer/UseButton
@onready var drop_button: Button = $MarginContainer/HBoxContainer/ItemDetailsPanel/MarginContainer/VBoxContainer/DropButton

var current_category: ItemData.ItemType = ItemData.ItemType.GEAR
var selected_item: ItemData = null

func _ready() -> void:
	gear_button.pressed.connect(func(): set_category(ItemData.ItemType.GEAR))
	consumables_button.pressed.connect(func(): set_category(ItemData.ItemType.CONSUMABLE))
	quest_button.pressed.connect(func(): set_category(ItemData.ItemType.QUEST))
	materials_button.pressed.connect(func(): set_category(ItemData.ItemType.MATERIAL))

	use_button.pressed.connect(use_selected_item)
	drop_button.pressed.connect(drop_selected_item)

	clear_item_details()
	refresh_inventory()

func set_category(category: ItemData.ItemType) -> void:
	current_category = category
	selected_item = null
	clear_item_details()
	refresh_inventory()

func refresh_inventory() -> void:
	for child in grid_container.get_children():
		child.queue_free()

	for item in GameManager.inventory:
		if item == null:
			continue

		if item.item_type != current_category:
			continue

		var slot = inventory_slot_scene.instantiate()
		grid_container.add_child(slot)
		slot.setup(item, 1)
		slot.slot_clicked.connect(on_slot_clicked)

func on_slot_clicked(item: ItemData) -> void:
	selected_item = item
	update_item_details()

func update_item_details() -> void:
	if selected_item == null:
		clear_item_details()
		return

	item_name_label.text = selected_item.display_name
	item_description_label.text = selected_item.description

	use_button.visible = selected_item.item_type == ItemData.ItemType.CONSUMABLE
	drop_button.visible = selected_item.item_type != ItemData.ItemType.QUEST

func clear_item_details() -> void:
	item_name_label.text = "No item selected"
	item_description_label.text = ""
	use_button.visible = false
	drop_button.visible = false

func use_selected_item() -> void:
	if selected_item == null:
		return

	if selected_item.item_type != ItemData.ItemType.CONSUMABLE:
		return

	print("Use item: ", selected_item.display_name)

func drop_selected_item() -> void:
	if selected_item == null:
		return

	if selected_item.item_type == ItemData.ItemType.QUEST:
		return

	GameManager.inventory.erase(selected_item)
	selected_item = null
	clear_item_details()
	refresh_inventory()
