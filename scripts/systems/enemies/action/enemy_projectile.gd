extends Area2D
class_name EnemyProjectile

@export var speed: float = 180.0
@export var lifetime: float = 5.0

var direction: Vector2 = Vector2.ZERO
var damage: int = 1
var source: Node2D = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)

	var lifetime_timer := get_tree().create_timer(lifetime)
	lifetime_timer.timeout.connect(queue_free)


func setup(
	start_position: Vector2,
	target_position: Vector2,
	projectile_damage: int,
	projectile_speed: float,
	projectile_source: Node2D
) -> void:
	global_position = start_position
	direction = start_position.direction_to(target_position)
	damage = projectile_damage
	speed = projectile_speed
	source = projectile_source

	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


func _on_body_entered(body: Node) -> void:
	if body == source:
		return

	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

		queue_free()
		return

	# Le projectile disparaît également contre un mur.
	queue_free()
