extends TextureButton

signal slot_clicked(item_data: ItemData)

@onready var icon: TextureRect = $CenterContainer/TextureRect
@onready var quantity_label: Label = $QuantityLabel

var item_data: ItemData
var quantity: int = 1

func _ready() -> void:
	pressed.connect(_on_pressed)

func setup(new_item_data: ItemData, new_quantity: int = 1) -> void:
	item_data = new_item_data
	quantity = new_quantity

	icon.texture = item_data.icon

	if quantity > 1:
		quantity_label.text = str(quantity)
		quantity_label.visible = true
	else:
		quantity_label.visible = false

func _on_pressed() -> void:
	slot_clicked.emit(item_data)
