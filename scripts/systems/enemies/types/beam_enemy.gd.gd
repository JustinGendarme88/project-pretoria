extends Enemy
class_name BeamEnemy

@export var beam_length: float = 300.0
@export var damage_tick: float = 0.5

var beam_active: bool = false
var beam_direction: Vector2 = Vector2.ZERO

@onready var ray_cast: RayCast2D = $RayCast2D
@onready var beam_line: Line2D = $Line2D
@onready var damage_tick_timer: Timer = $DamageTickTimer


func _ready() -> void:
	super._ready()

	beam_line.visible = false
	ray_cast.enabled = false

	damage_tick_timer.wait_time = damage_tick
	damage_tick_timer.timeout.connect(_on_damage_tick)


func try_attack() -> void:
	if beam_active:
		return

	if target == null or not is_instance_valid(target):
		return

	activate_beam()


func activate_beam() -> void:
	beam_active = true
	can_attack = false

	beam_direction = global_position.direction_to(target.global_position)

	var beam_target := beam_direction * beam_length

	ray_cast.target_position = beam_target
	ray_cast.enabled = true

	beam_line.clear_points()
	beam_line.add_point(Vector2.ZERO)
	beam_line.add_point(beam_target)
	beam_line.visible = true

	damage_tick_timer.start()


func _on_damage_tick() -> void:
	if not beam_active or is_dead:
		return

	ray_cast.force_raycast_update()

	if not ray_cast.is_colliding():
		return

	var collider := ray_cast.get_collider()

	if collider == null:
		return

	if collider.is_in_group("player") and collider.has_method("take_damage"):
		var result := calculate_damage()
		collider.take_damage(result.damage)

		if result.is_critical:
			print(data.display_name + " landed a critical beam hit!")
