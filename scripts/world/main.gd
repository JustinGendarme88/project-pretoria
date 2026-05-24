extends Node

func _ready() -> void:
	await get_tree().process_frame
	
	var quest: QuestData = preload("res://data/quests/find_supply_bag.tres")
	
	QuestManager.register_quest(quest)
	QuestManager.start_quest("find_supply_bag")
	
	print(QuestManager.quest_states)
	
	QuestManager.complete_current_step("find_supply_bag")

	print(QuestManager.quest_states)
