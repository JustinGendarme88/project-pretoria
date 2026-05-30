extends Area2D

@export_enum("north", "south", "east", "west") var direction: String = "north"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	print("Body entered exit: ", body.name)

	if not body.is_in_group("player"):
		print("Not player")
		return

	var dungeon_main = get_tree().get_first_node_in_group("dungeon_main")
	if dungeon_main == null:
		print("DungeonMain not found")
		return

	if dungeon_main == null or not dungeon_main.has_method("load_next_room"):
		print("DungeonMain not found")
		return

	dungeon_main.call_deferred("load_next_room", direction)
