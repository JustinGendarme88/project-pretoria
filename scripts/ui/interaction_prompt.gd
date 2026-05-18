extends CanvasLayer

@onready var label: Label = $Panel/Label

func _ready() -> void:
	hide()


func show_prompt(text: String) -> void:
	label.text = text
	show()


func hide_prompt() -> void:
	hide()
