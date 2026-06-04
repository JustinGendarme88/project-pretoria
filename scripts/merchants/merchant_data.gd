extends Resource
class_name MerchantData

@export var merchant_id: String
@export var merchant_name: String

@export var gold: int = 100

@export var buy_multiplier: float = 1.0
@export var sell_multiplier: float = 1.0

@export var stock: Array[MerchantStockEntry] = []
