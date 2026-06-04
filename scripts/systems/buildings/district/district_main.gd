extends Node2D

@onready var merchant_shop_ui: CanvasLayer = get_tree().current_scene.get_node("MerchantShopUi")

func _ready() -> void:
	await get_tree().process_frame
	
	EconomyManager.gold = 100
	
	var merchant: MerchantData = preload("res://data/merchants/blacksmith_merchant.tres")
	merchant_shop_ui.open_shop(merchant)
