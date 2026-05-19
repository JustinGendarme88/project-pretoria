extends CanvasLayer

var is_open: bool = false

func _ready() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_menu()

func toggle_menu() -> void:
	if is_open:
		close_menu()
	else:
		open_menu()

func open_menu() -> void:
	is_open = true
	visible = true
	GameManager.ui_open = true

func close_menu() -> void:
	is_open = false
	visible = false
	GameManager.ui_open = false
