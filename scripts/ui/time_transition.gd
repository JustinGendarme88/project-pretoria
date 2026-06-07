extends CanvasLayer

@onready var black_screen: ColorRect = $ColorRect
@onready var message_label: Label = $Label

var is_transitioning := false


func _ready() -> void:
	black_screen.modulate.a = 0.0
	message_label.modulate.a = 0.0
	message_label.text = ""

	GameManager.register_time_transition(self)


func pass_time(steps: int = 1, message: String = "") -> void:
	if is_transitioning:
		return

	is_transitioning = true
	GameManager.is_time_transition = true

	var was_paused := get_tree().paused
	get_tree().paused = true

	await fade_to_black()

	if message != "":
		message_label.text = message
		await fade_message_in()
		await get_tree().create_timer(1.5, true).timeout
		await fade_message_out()

	for i in steps:
		TimeManager.advance_time()

	await get_tree().create_timer(0.3, true).timeout

	await fade_from_black()

	get_tree().paused = was_paused
	GameManager.is_time_transition = false
	is_transitioning = false

func fade_to_black() -> void:
	var tween := create_tween()
	tween.tween_property(black_screen, "modulate:a", 1.0, 0.8)
	await tween.finished


func fade_from_black() -> void:
	var tween := create_tween()
	tween.tween_property(black_screen, "modulate:a", 0.0, 0.8)
	await tween.finished


func fade_message_in() -> void:
	var tween := create_tween()
	tween.tween_property(message_label, "modulate:a", 1.0, 0.4)
	await tween.finished


func fade_message_out() -> void:
	var tween := create_tween()
	tween.tween_property(message_label, "modulate:a", 0.0, 0.4)
	await tween.finished
