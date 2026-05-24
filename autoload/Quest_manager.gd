extends Node

signal quests_changed

enum QuestStatus {
	NOT_STARTED,
	ACTIVE,
	COMPLETED,
	FAILED
}

var quests: Dictionary = {}
var quest_states: Dictionary = {}


func register_quest(quest: QuestData) -> void:
	if quest == null:
		return
	
	if quest.id == "":
		push_warning("Quest without id ignored.")
		return
	
	quests[quest.id] = quest
	
	if not quest_states.has(quest.id):
		quest_states[quest.id] = {
			"status": QuestStatus.NOT_STARTED,
			"current_step_id": "",
			"completed_steps": [],
			"failed_steps": [],
			"discovered": false
		}
	
	quests_changed.emit()


func start_quest(quest_id: String) -> void:
	if not quest_states.has(quest_id):
		push_warning("Quest not registered: " + quest_id)
		return
	
	var quest: QuestData = quests.get(quest_id)
	if quest == null or quest.steps.is_empty():
		return
	
	quest_states[quest_id]["status"] = QuestStatus.ACTIVE
	quest_states[quest_id]["current_step_id"] = quest.steps[0].id
	quest_states[quest_id]["discovered"] = true
	
	quests_changed.emit()


func complete_step(quest_id: String, step_id: String) -> void:
	if not quest_states.has(quest_id):
		return
	
	var state: Dictionary = quest_states[quest_id]
	
	if not step_id in state["completed_steps"]:
		state["completed_steps"].append(step_id)
	
	var quest: QuestData = quests.get(quest_id)
	if quest == null:
		return
	
	var next_step_id := get_next_step_id(quest, step_id)
	
	if next_step_id == "":
		complete_quest(quest_id)
	else:
		state["current_step_id"] = next_step_id
	
	quests_changed.emit()


func complete_current_step(quest_id: String) -> void:
	if not quest_states.has(quest_id):
		return
	
	var current_step_id: String = quest_states[quest_id]["current_step_id"]
	if current_step_id == "":
		return
	
	complete_step(quest_id, current_step_id)


func complete_quest(quest_id: String) -> void:
	if not quest_states.has(quest_id):
		return
	
	quest_states[quest_id]["status"] = QuestStatus.COMPLETED
	quest_states[quest_id]["current_step_id"] = ""
	quests_changed.emit()


func fail_quest(quest_id: String) -> void:
	if not quest_states.has(quest_id):
		return
	
	quest_states[quest_id]["status"] = QuestStatus.FAILED
	quests_changed.emit()


func get_next_step_id(quest: QuestData, step_id: String) -> String:
	for i in quest.steps.size():
		if quest.steps[i].id == step_id:
			var next_index := i + 1
			
			if next_index < quest.steps.size():
				return quest.steps[next_index].id
			
			return ""
	
	return ""


func get_active_quests() -> Array[QuestData]:
	var result: Array[QuestData] = []
	
	for quest_id in quest_states.keys():
		if quest_states[quest_id]["status"] == QuestStatus.ACTIVE:
			result.append(quests[quest_id])
	
	return result


func get_discovered_quests() -> Array[QuestData]:
	var result: Array[QuestData] = []
	
	for quest_id in quest_states.keys():
		if quest_states[quest_id]["discovered"]:
			result.append(quests[quest_id])
	
	return result


func get_quest_state(quest_id: String) -> Dictionary:
	return quest_states.get(quest_id, {})


func is_step_completed(quest_id: String, step_id: String) -> bool:
	if not quest_states.has(quest_id):
		return false
	
	return step_id in quest_states[quest_id]["completed_steps"]


func is_current_step(quest_id: String, step_id: String) -> bool:
	if not quest_states.has(quest_id):
		return false
	
	return quest_states[quest_id]["current_step_id"] == step_id

func get_save_data() -> Dictionary:
	return quest_states.duplicate(true)


func load_save_data(data: Dictionary) -> void:
	quest_states = data.duplicate(true)
	quests_changed.emit()
