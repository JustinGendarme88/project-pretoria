extends CharacterBody2D
class_name Enemy

@export var data: EnemyData

var current_hp: int = 1
var target: Node2D = null
var can_attack: bool = true
var is_dead: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_cooldown_timer: Timer = $AttackCooldown


func _ready() -> void:
	if data == null:
		push_warning("Enemy has no EnemyData assigned.")
		return

	current_hp = data.max_hp

	if sprite != null:
		sprite.texture = data.texture
		sprite.scale = Vector2.ONE * data.scale_multiplier

	if attack_cooldown_timer != null:
		attack_cooldown_timer.wait_time = data.attack_cooldown
		attack_cooldown_timer.timeout.connect(_on_attack_cooldown_timeout)


func _physics_process(_delta: float) -> void:
	if is_dead or data == null:
		return

	find_target()

	if target == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var distance_to_target := global_position.distance_to(target.global_position)

	if distance_to_target <= data.attack_range:
		velocity = Vector2.ZERO
		move_and_slide()
		try_attack()
	else:
		move_towards_target()


func find_target() -> void:
	if target != null and is_instance_valid(target):
		var distance := global_position.distance_to(target.global_position)
		if distance <= data.detection_range:
			return

	target = get_tree().get_first_node_in_group("player")

	if target != null:
		var distance := global_position.distance_to(target.global_position)
		if distance > data.detection_range:
			target = null


func move_towards_target() -> void:
	if data.movement_type == "Static":
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction := global_position.direction_to(target.global_position)
	var speed := get_movement_speed()

	velocity = direction * speed
	move_and_slide()


func get_movement_speed() -> float:
	match data.movement_type:
		"Slow":
			return data.move_speed * 0.6
		"Fast":
			return data.move_speed * 1.4
		_:
			return data.move_speed


func try_attack() -> void:
	if not can_attack:
		return

	can_attack = false
	attack()

	if attack_cooldown_timer != null:
		attack_cooldown_timer.start()


func attack() -> void:
	if target == null or not is_instance_valid(target):
		return

	var result := calculate_damage()

	if target.has_method("take_damage"):
		target.take_damage(result.damage)

	if result.is_critical:
		print(data.display_name + " landed a critical hit!")


func calculate_damage() -> Dictionary:
	var damage: int = max(1, data.attack)
	var is_critical := randf() < data.critical_chance

	if is_critical:
		damage = int(round(float(damage) * data.critical_multiplier))

	return {
		"damage": damage,
		"is_critical": is_critical
	}


func take_damage(amount: int) -> void:
	if is_dead:
		return

	var final_damage: int = max(1, amount - data.defense)
	current_hp -= final_damage

	if current_hp <= 0:
		die()


func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	queue_free()


func _on_attack_cooldown_timeout() -> void:
	can_attack = true
