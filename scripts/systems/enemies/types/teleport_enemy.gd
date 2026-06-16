extends Enemy
class_name TeleportEnemy

@export var teleport_distance: float = 96.0
@export var teleport_cooldown: float = 3.0

var can_teleport: bool = true


func move_towards_target() -> void:
	if target == null:
		return

	if can_teleport:
		teleport_near_target()
	else:
		super.move_towards_target()


func teleport_near_target() -> void:
	can_teleport = false

	var random_direction := Vector2.RIGHT.rotated(randf_range(0.0, TAU))
	global_position = target.global_position + random_direction * teleport_distance

	await get_tree().create_timer(teleport_cooldown).timeout
	can_teleport = true
