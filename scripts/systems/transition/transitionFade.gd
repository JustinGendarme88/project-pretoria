extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

var tween: Tween


func _ready() -> void:
	layer = 100
	visible = true

	color_rect.visible = true
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.color = Color.BLACK
	color_rect.modulate = Color(1, 1, 1, 0)


func fade_out(duration: float = 0.6) -> void:
	print("FADE OUT START: ", duration)

	if tween:
		tween.kill()

	color_rect.modulate.a = 0.0

	tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)

	await tween.finished

	print("FADE OUT END")


func fade_in(duration: float = 0.6) -> void:
	print("FADE IN START: ", duration)

	if tween:
		tween.kill()

	color_rect.modulate.a = 1.0

	tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect, "modulate:a", 0.0, duration)

	await tween.finished

	print("FADE IN END")
