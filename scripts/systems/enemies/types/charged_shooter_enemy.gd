extends Enemy
class_name ChargedShooterEnemy

@export_category("Projectile")
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 130.0

@export_category("Charge")
@export_range(0.1, 5.0, 0.1)
var charge_duration: float = 1.5

var is_charging: bool = false
var charged_target: Node2D = null

@onready var charge_timer: Timer = $ChargeTimer

func _ready() -> void:
	super._ready()

	charge_timer.one_shot = true
	charge_timer.wait_time = charge_duration

	if not charge_timer.timeout.is_connected(_on_charge_timer_timeout):
		charge_timer.timeout.connect(_on_charge_timer_timeout)


func _physics_process(_delta: float) -> void:
	if is_dead or data == null:
		return

	# Pendant la charge, on ne recherche plus de nouvelle cible.
	# Cela évite que target soit perdu si le joueur s'éloigne.
	if is_charging:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	find_target()

	if target == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var distance_to_target := global_position.distance_to(
		target.global_position
	)

	if distance_to_target <= data.attack_range:
		velocity = Vector2.ZERO
		move_and_slide()
		try_attack()
	else:
		move_towards_target()


func try_attack() -> void:
	if not can_attack:
		return

	if is_charging:
		return

	if target == null or not is_instance_valid(target):
		return

	start_charge()


func start_charge() -> void:
	is_charging = true
	can_attack = false
	velocity = Vector2.ZERO

	# On mémorise le joueur ayant déclenché la charge.
	charged_target = target

	charge_timer.wait_time = charge_duration
	charge_timer.start()

	print(data.display_name + " started charging.")


func _on_charge_timer_timeout() -> void:
	if is_dead:
		return

	is_charging = false

	if charged_target != null and is_instance_valid(charged_target):
		shoot_projectile(charged_target.global_position)

	charged_target = null

	if attack_cooldown_timer != null:
		attack_cooldown_timer.start()
	else:
		can_attack = true


func shoot_projectile(target_position: Vector2) -> void:
	if projectile_scene == null:
		push_warning("Charged Shooter has no projectile scene assigned.")
		return

	var projectile := projectile_scene.instantiate() as EnemyProjectile

	if projectile == null:
		push_warning(
			"The assigned projectile scene does not use EnemyProjectile."
		)
		return

	var result := calculate_damage()

	get_tree().current_scene.add_child(projectile)

	projectile.setup(
		global_position,
		target_position,
		result.damage,
		projectile_speed,
		self
	)

	if result.is_critical:
		print(data.display_name + " landed a critical charged hit!")


func die() -> void:
	if is_dead:
		return

	charge_timer.stop()
	is_charging = false
	charged_target = null

	super.die()
