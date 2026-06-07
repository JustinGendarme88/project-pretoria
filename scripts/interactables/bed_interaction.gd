extends Area2D

var player_in_range := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if not player_in_range:
		return

	if GameManager.is_time_transition:
		return

	if Input.is_action_just_pressed("interact"):
		if GameManager.time_transition == null:
			push_warning("No TimeTransition registered.")
			return

		var message := ""

		if TimeManager.day_part == TimeManager.DayPart.DAY:
			message = "You rest until nightfall..."
		else:
			message = "You rest until morning..."

		await GameManager.time_transition.pass_time(1, message)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false
