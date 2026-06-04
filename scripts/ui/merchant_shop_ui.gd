extends CanvasLayer

@export var inventory_slot_scene: PackedScene

@onready var title_label: Label = find_child("TitleLabel", true, false)
@onready var gold_label: Label = find_child("GoldLabel", true, false)

@onready var merchant_grid: GridContainer = find_child("MerchantGrid", true, false)
@onready var player_grid: GridContainer = find_child("PlayerGrid", true, false)

@onready var item_name_label: Label = find_child("ItemNameLabel", true, false)
@onready var item_description_label: Label = find_child("ItemDescriptionLabel", true, false)
@onready var price_label: Label = find_child("PriceLabel", true, false)
@onready var action_button: Button = find_child("ActionButton", true, false)

@onready var close_button: Button = find_child("CloseButton", true, false)

var current_merchant: MerchantData = null
var selected_item: ItemData = null
var selected_entry: MerchantStockEntry = null
var selected_mode: String = ""


func _ready() -> void:
	layer = 10
	visible = false
	
	action_button.pressed.connect(_on_action_pressed)
	close_button.pressed.connect(close_shop)
	
	InventoryManager.inventory_updated.connect(refresh)
	EconomyManager.gold_changed.connect(func(_gold): refresh())
	
	clear_details()


func open_shop(merchant_data: MerchantData) -> void:
	if merchant_data == null:
		return
	
	current_merchant = merchant_data
	visible = true
	refresh()


func close_shop() -> void:
	visible = false
	current_merchant = null
	selected_item = null
	selected_entry = null
	selected_mode = ""
	clear_details()


func refresh() -> void:
	if current_merchant == null:
		return
	
	title_label.text = current_merchant.merchant_name
	gold_label.text = "Gold: " + str(EconomyManager.gold) + " | Merchant gold: " + str(current_merchant.gold)
	
	refresh_merchant_stock()
	refresh_player_inventory()
	clear_details()


func refresh_merchant_stock() -> void:
	for child in merchant_grid.get_children():
		child.queue_free()
	
	for entry in current_merchant.stock:
		if entry == null or entry.item == null:
			continue
		
		if entry.quantity == 0:
			continue
		
		var displayed_quantity := entry.quantity
		if displayed_quantity < 0:
			displayed_quantity = 1
		
		var slot = inventory_slot_scene.instantiate()
		merchant_grid.add_child(slot)
		
		slot.custom_minimum_size = Vector2(64, 64)
		slot.size = Vector2(64, 64)
		
		slot.setup(entry.item, displayed_quantity)
		slot.slot_clicked.connect(func(_item): select_buy_entry(entry))


func refresh_player_inventory() -> void:
	for child in player_grid.get_children():
		child.queue_free()
	
	for item in InventoryManager.get_all_items():
		if item == null:
			continue
		
		var slot = inventory_slot_scene.instantiate()
		player_grid.add_child(slot)
		
		slot.custom_minimum_size = Vector2(64, 64)
		slot.size = Vector2(64, 64)
		
		slot.setup(item, 1)
		slot.slot_clicked.connect(func(clicked_item): select_sell_item(clicked_item))


func select_buy_entry(entry: MerchantStockEntry) -> void:
	selected_entry = entry
	selected_item = entry.item
	selected_mode = "buy"
	
	item_name_label.text = selected_item.display_name
	item_description_label.text = selected_item.description
	price_label.text = "Buy price: " + str(MerchantManager.get_buy_price(entry, current_merchant)) + " gold"
	action_button.text = "Buy"
	action_button.visible = true


func select_sell_item(item: ItemData) -> void:
	selected_item = item
	selected_entry = null
	selected_mode = "sell"
	
	item_name_label.text = selected_item.display_name
	item_description_label.text = selected_item.description
	price_label.text = "Sell price: " + str(MerchantManager.get_sell_price(item, current_merchant)) + " gold"
	action_button.text = "Sell"
	action_button.visible = true


func clear_details() -> void:
	item_name_label.text = "No item selected"
	item_description_label.text = ""
	price_label.text = ""
	action_button.visible = false


func _on_action_pressed() -> void:
	if current_merchant == null:
		return
	
	if selected_mode == "buy" and selected_entry != null:
		MerchantManager.buy_item(selected_entry, current_merchant)
	elif selected_mode == "sell" and selected_item != null:
		MerchantManager.sell_item(selected_item, current_merchant)
	
	selected_item = null
	selected_entry = null
	selected_mode = ""
	refresh()
