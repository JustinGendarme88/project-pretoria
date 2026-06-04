extends Node

signal merchant_transaction_completed
signal merchant_transaction_failed(reason: String)


func get_buy_price(entry: MerchantStockEntry, merchant_data: MerchantData) -> int:
	if entry == null or entry.item == null:
		return 0

	var base_price := entry.custom_buy_price
	
	if base_price <= 0:
		base_price = entry.item.buy_price

	return max(1, int(base_price * merchant_data.buy_multiplier))


func get_sell_price(item: ItemData, merchant_data: MerchantData) -> int:
	if item == null:
		return 0

	if not item.sellable:
		return 0

	var base_price := item.sell_price
	var economy_price := EconomyManager.calculate_sell_price(item.id, base_price)

	return max(1, int(economy_price * merchant_data.sell_multiplier))


func can_buy(entry: MerchantStockEntry, merchant_data: MerchantData) -> bool:
	if entry == null or entry.item == null:
		return false

	if entry.quantity == 0:
		return false

	var price := get_buy_price(entry, merchant_data)
	return EconomyManager.can_afford(price)


func buy_item(entry: MerchantStockEntry, merchant_data: MerchantData) -> bool:
	if not can_buy(entry, merchant_data):
		merchant_transaction_failed.emit("Cannot buy item")
		return false

	var price := get_buy_price(entry, merchant_data)

	if not EconomyManager.remove_gold(price):
		merchant_transaction_failed.emit("Not enough gold")
		return false

	InventoryManager.add_item(entry.item)
	merchant_data.gold += price

	if entry.quantity > 0:
		entry.quantity -= 1

	merchant_transaction_completed.emit()
	return true


func can_sell(item: ItemData, merchant_data: MerchantData) -> bool:
	if item == null:
		return false

	if not item.sellable:
		return false

	var price := get_sell_price(item, merchant_data)

	if price <= 0:
		return false

	if merchant_data.gold < price:
		return false

	return InventoryManager.has_item(item.id)


func sell_item(item: ItemData, merchant_data: MerchantData) -> bool:
	if not can_sell(item, merchant_data):
		merchant_transaction_failed.emit("Cannot sell item")
		return false

	var price := get_sell_price(item, merchant_data)

	InventoryManager.remove_item(item)
	EconomyManager.add_gold(price)
	EconomyManager.register_sold_item(item.id)

	merchant_data.gold -= price

	merchant_transaction_completed.emit()
	return true
