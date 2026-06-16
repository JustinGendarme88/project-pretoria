extends Enemy
class_name BossEnemy

@export var phase_two_threshold: float = 0.5

var phase: int = 1


func _physics_process(delta: float) -> void:
	if data == null or is_dead:
		return

	update_phase()
	super._physics_process(delta)


func update_phase() -> void:
	var hp_ratio := float(current_hp) / float(data.max_hp)

	if phase == 1 and hp_ratio <= phase_two_threshold:
		phase = 2
		on_phase_two_started()


func on_phase_two_started() -> void:
	print(data.display_name + " entered phase 2!")

	data.attack += 2
	data.move_speed *= 1.2
	data.attack_cooldown *= 0.8

	if attack_cooldown_timer != null:
		attack_cooldown_timer.wait_time = data.attack_cooldown


func attack() -> void:
	if phase == 1:
		super.attack()
	else:
		phase_two_attack()


func phase_two_attack() -> void:
	super.attack()
	print(data.display_name + " uses a stronger phase 2 attack!")
