extends Area2D
class_name TransitionArea

@export var target_scene_path: String = ""
@export var target_spawn_id: String = "default"
@export var autosave_on_transition: bool = true

var transition_started := false


func _ready() -> void:
	print("TransitionArea READY")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	print("BODY ENTERED: ", body.name)

	if transition_started:
		print("Transition already started.")
		return

	print("GROUP PLAYER: ", body.is_in_group("player"))

	if not body.is_in_group("player"):
		return

	print("TRANSITION START")

	if target_scene_path == "":
		push_warning("TransitionArea has no target_scene_path.")
		return

	transition_started = true
	call_deferred("_start_transition")


func _start_transition() -> void:
	if autosave_on_transition:
		await SaveManager.create_autosave()

	await GameManager.change_zone(target_scene_path, target_spawn_id)
