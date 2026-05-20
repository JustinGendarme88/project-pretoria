extends PanelContainer

signal slot_clicked(item_data: ItemData)

@onready var icon: TextureRect = $Control/TextureRect
@onready var quantity_label: Label = $Control/QuantityLabel

var item_data: ItemData
var quantity: int = 1

func _ready() -> void:
	print("InventorySlot ready")
	$Control.gui_input.connect(_on_control_gui_input)
	
func setup(new_item_data: ItemData, new_quantity: int = 1) -> void:
	item_data = new_item_data
	quantity = new_quantity

	icon.texture = item_data.icon

	if quantity > 1:
		quantity_label.text = str(quantity)
		quantity_label.visible = true
	else:
		quantity_label.visible = false



func _on_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("Slot clicked: ", item_data.display_name)
			slot_clicked.emit(item_data)
