extends Enemy
class_name SlimeEnemy

@export var small_slime_scene: PackedScene
@export var split_count: int = 2

var has_split: bool = false


func take_damage(amount: int) -> void:
	if is_dead:
		return

	super.take_damage(amount)

	if is_dead:
		return

	if not has_split and current_hp <= data.max_hp / 2:
		split()


func split() -> void:
	if small_slime_scene == null:
		return

	has_split = true

	var hp_per_slime: int = max(1, current_hp / split_count)

	for i in split_count:
		var slime := small_slime_scene.instantiate()

		get_parent().add_child(slime)

		slime.global_position = global_position + Vector2(
			randf_range(-16.0, 16.0),
			randf_range(-16.0, 16.0)
		)

		if slime is Enemy:
			slime.current_hp = hp_per_slime

	queue_free()
