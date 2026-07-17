extends Enemy
class_name ChargedShooterEnemy

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 130.0
@export_range(0.1, 5.0, 0.1)
var charge_time: float = 1.5

var is_charging: bool = false


func try_attack() -> void:
	if not can_attack or is_charging:
		return

	if target == null or not is_instance_valid(target):
		return

	can_attack = false
	is_charging = true

	print(data.display_name + " is charging an attack.")

	await get_tree().create_timer(charge_time).timeout

	if is_dead:
		return

	if target != null and is_instance_valid(target):
		shoot_projectile()

	is_charging = false

	if attack_cooldown_timer != null:
		attack_cooldown_timer.start()
	else:
		can_attack = true


func shoot_projectile() -> void:
	if projectile_scene == null:
		push_warning("Charged shooter has no projectile scene assigned.")
		return

	var projectile := projectile_scene.instantiate() as EnemyProjectile

	if projectile == null:
		push_warning("The projectile scene does not use EnemyProjectile.")
		return

	var result := calculate_damage()

	get_tree().current_scene.add_child(projectile)

	projectile.setup(
		global_position,
		target.global_position,
		result.damage,
		projectile_speed,
		self
	)

	if result.is_critical:
		print(data.display_name + " landed a critical charged hit!")
