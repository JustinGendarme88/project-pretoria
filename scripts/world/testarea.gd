extends Node

@onready var merchant_shop_ui = $MerchantShopUi

func _ready() -> void:
	var merchant: MerchantData = preload("res://data/merchants/blacksmith_merchant.tres")
	merchant_shop_ui.open_shop(merchant)
