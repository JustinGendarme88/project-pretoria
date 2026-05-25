extends Node

@onready var world_container: Node2D = $WorldContainer
@onready var transition_fade: CanvasLayer = $TransitionFade
@onready var location_banner: CanvasLayer = $LocationBanner

func _ready() -> void:
	await get_tree().process_frame

	GameManager.register_world_container(world_container)
	print("MAIN registered WorldContainer: ", world_container)

	if GameManager.current_world_scene_path == "":
		var current_world := world_container.get_child(0)
		if current_world.scene_file_path != "":
			GameManager.current_world_scene_path = current_world.scene_file_path

	_register_quests()
	GameManager.register_transition_fade(transition_fade)
	GameManager.register_location_banner(location_banner)
	print("LocationBanner registered: ", location_banner)


func _register_quests() -> void:
	var quest: QuestData = preload("res://data/quests/find_supply_bag.tres")

	QuestManager.register_quest(quest)

	if not QuestManager.get_quest_state("find_supply_bag").get("discovered", false):
		QuestManager.start_quest("find_supply_bag")
