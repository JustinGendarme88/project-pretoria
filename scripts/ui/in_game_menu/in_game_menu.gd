extends CanvasLayer

@onready var tab_container: TabContainer = $Panel/MarginContainer/TabContainer

var is_open: bool = false

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	tab_container.set_tab_title(0, "Inventory")
	tab_container.set_tab_title(1, "Status")
	tab_container.set_tab_title(2, "Reputation")
	tab_container.set_tab_title(3, "Options")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
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
	get_tree().paused = true

func close_menu() -> void:
	is_open = false
	visible = false
	GameManager.ui_open = false
	get_tree().paused = false
