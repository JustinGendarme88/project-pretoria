extends Node

var reputations: Dictionary = {}

const MIN_REPUTATION := -100
const MAX_REPUTATION := 100

func register_npc(npc_id: String, starting_reputation: int = 0) -> void:
	if npc_id == "":
		return

	if not reputations.has(npc_id):
		reputations[npc_id] = clamp(starting_reputation, MIN_REPUTATION, MAX_REPUTATION)


func get_reputation(npc_id: String) -> int:
	return reputations.get(npc_id, 0)


func set_reputation(npc_id: String, value: int) -> void:
	if npc_id == "":
		return

	reputations[npc_id] = clamp(value, MIN_REPUTATION, MAX_REPUTATION)


func change_reputation(npc_id: String, amount: int) -> void:
	if npc_id == "":
		return

	var current_value := get_reputation(npc_id)
	set_reputation(npc_id, current_value + amount)


func get_reputation_level(npc_id: String) -> String:
	var value := get_reputation(npc_id)

	if value >= 75:
		return "trusted"
	elif value >= 25:
		return "friendly"
	elif value > -25:
		return "neutral"
	elif value > -75:
		return "unfriendly"
	else:
		return "hostile"


func can_trade_with(npc_id: String) -> bool:
	return get_reputation(npc_id) > -50


func get_save_data() -> Dictionary:
	return reputations.duplicate(true)


func load_save_data(data: Dictionary) -> void:
	reputations = data.duplicate(true)
