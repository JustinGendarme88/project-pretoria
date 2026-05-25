extends CanvasLayer

@onready var label: Label = $MarginContainer/Label

var tween: Tween


func _ready() -> void:
	layer = 90
	visible = true
	label.modulate.a = 0.0


func show_location(location_name: String) -> void:
	print("SHOW_LOCATION CALLED: ", location_name)
	if location_name == "":
		return

	if tween:
		tween.kill()

	label.text = location_name
	label.modulate.a = 0.0

	tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	tween.tween_property(label, "modulate:a", 1.0, 0.4)
	tween.tween_interval(2.0)
	tween.tween_property(label, "modulate:a", 0.0, 0.6)

	await tween.finished
