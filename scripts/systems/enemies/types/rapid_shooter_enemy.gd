extends Enemy
class_name RapidShooterEnemy

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 220.0


func attack() -> void:
	if target == null or not is_instance_valid(target):
		return

	if projectile_scene == null:
		push_warning("Rapid shooter has no projectile scene assigned.")
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
		print(data.display_name + " landed a critical projectile hit!")
