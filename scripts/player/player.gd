extends CharacterBody2D

enum PlayerState {
	NORMAL,
	DIALOGUE,
	ATTACKING,
	MENU,
	DEAD
}

@onready var camera: Camera2D = $Camera2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea

@export var speed: float = 180.0

var state: PlayerState = PlayerState.NORMAL

var is_attacking: bool = false
var attack_damage: int = 1

var last_direction: String = "down"


func _ready() -> void:
	z_index = 10

	set_state(PlayerState.NORMAL)
	add_to_group("player")
	GameManager.register_player(self)

	if not PlayerStats.player_died.is_connected(die):
		PlayerStats.player_died.connect(die)

	await get_tree().process_frame
	_apply_camera_limits()


func _process(_delta: float) -> void:
	if state != PlayerState.NORMAL:
		return

	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()


func _physics_process(_delta: float) -> void:
	if state != PlayerState.NORMAL:
		stop_player()
		return

	var direction := Vector2.ZERO

	direction.x = (
		Input.get_action_strength("move_right")
		- Input.get_action_strength("move_left")
	)

	direction.y = (
		Input.get_action_strength("move_down")
		- Input.get_action_strength("move_up")
	)

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		update_last_direction(direction)
		play_walk_animation()
	else:
		play_idle_animation()

	velocity = direction * speed
	move_and_slide()


func set_state(new_state: PlayerState) -> void:
	state = new_state

	match state:
		PlayerState.NORMAL:
			is_attacking = false
			play_idle_animation()

		PlayerState.DIALOGUE:
			is_attacking = false
			stop_player()

		PlayerState.ATTACKING:
			stop_player()

		PlayerState.MENU:
			is_attacking = false
			stop_player()

		PlayerState.DEAD:
			is_attacking = false
			velocity = Vector2.ZERO
			set_process(false)
			set_physics_process(false)


func stop_player() -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	play_idle_animation()


func update_last_direction(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			last_direction = "right"
		else:
			last_direction = "left"
	else:
		if direction.y > 0:
			last_direction = "down"
		else:
			last_direction = "up"


func play_walk_animation() -> void:
	var animation_name := "walk_" + last_direction

	if animated_sprite.animation != animation_name:
		animated_sprite.play(animation_name)


func play_idle_animation() -> void:
	var animation_name := "idle_" + last_direction

	if animated_sprite.animation != animation_name:
		animated_sprite.play(animation_name)


func update_attack_direction() -> void:
	match last_direction:
		"down":
			attack_area.position = Vector2(0, 28)

		"up":
			attack_area.position = Vector2(0, -28)

		"left":
			attack_area.position = Vector2(-28, 0)

		"right":
			attack_area.position = Vector2(28, 0)


func attack() -> void:
	if state != PlayerState.NORMAL:
		return

	set_state(PlayerState.ATTACKING)
	is_attacking = true
	update_attack_direction()

	# Temporaire : à remplacer plus tard par la fin
	# de l'animation d'attaque.
	await get_tree().create_timer(0.25).timeout

	if state == PlayerState.ATTACKING:
		is_attacking = false
		set_state(PlayerState.NORMAL)


func take_damage(amount: int) -> void:
	if state == PlayerState.DEAD:
		return

	if amount <= 0:
		return

	PlayerStats.take_damage(amount)


func die() -> void:
	if state == PlayerState.DEAD:
		return

	set_state(PlayerState.DEAD)


func reset_player() -> void:
	PlayerStats.set_health(PlayerStats.max_health)

	visible = true
	velocity = Vector2.ZERO

	set_process(true)
	set_physics_process(true)
	set_state(PlayerState.NORMAL)


func _apply_camera_limits() -> void:
	var bounds_nodes := get_tree().get_nodes_in_group("camera_bounds")

	if bounds_nodes.is_empty():
		return

	var bounds := bounds_nodes[0] as CameraBounds

	if bounds == null:
		push_warning("The camera_bounds node is not a CameraBounds.")
		return

	camera.limit_left = bounds.limit_left
	camera.limit_top = bounds.limit_top
	camera.limit_right = bounds.limit_right
	camera.limit_bottom = bounds.limit_bottom
