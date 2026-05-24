extends Area2D
class_name TransitionArea

@export_file("*.tscn") var target_scene_path: String
@export var target_spawn_id: String = "default"
@export var autosave_on_transition: bool = true

var player_in_area := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	if target_scene_path == "":
		push_warning("TransitionArea has no target_scene_path.")
		return

	if autosave_on_transition:
		await SaveManager.create_autosave()

	await GameManager.change_zone(target_scene_path, target_spawn_id)
