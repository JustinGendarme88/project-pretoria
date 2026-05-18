extends CharacterBody2D
class_name NPC

@export var data: NPCData
@export var interaction_area_path: NodePath = "Area2D"

var player_in_range: bool = false

@onready var interaction_area: Area2D = get_node_or_null(interaction_area_path)

var can_interact: bool = true

var interaction_prompt = null

func _ready() -> void:
	add_to_group("npc")
	interaction_prompt = get_tree().get_first_node_in_group("interaction_prompt")
	if data == null:
		push_warning("NPC has no NPCData assigned.")
		return

	ReputationManager.register_npc(data.id, data.starting_reputation)

	if interaction_area == null:
		push_warning("NPC has no interaction Area2D: " + data.display_name)
		return

	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	


func _process(_delta: float) -> void:
	if DialogueManager.is_dialogue_active:
		return

	if not player_in_range:
		return

	if not can_interact:
		return

	if Input.is_action_just_pressed("interact"):
		can_interact = false

		if interaction_prompt != null:
			interaction_prompt.hide_prompt()

		interact()


func interact() -> void:
	if data == null:
		return

	match data.npc_type:
		NPCData.NPCType.MERCHANT:
			interact_merchant()

		NPCData.NPCType.QUEST_GIVER:
			interact_dialogue()

		NPCData.NPCType.COMPANION:
			interact_dialogue()

		NPCData.NPCType.ENEMY_NEUTRAL:
			interact_dialogue()

		_:
			interact_dialogue()


func interact_dialogue() -> void:
	if data.dialogue_path == "":
		push_warning("NPC has no dialogue_path: " + data.display_name)
		return

	DialogueManager.start_dialogue(data.dialogue_path, data.id, data)


func interact_merchant() -> void:
	if data.merchant_shop_id == "":
		interact_dialogue()
		return

	if not ReputationManager.can_trade_with(data.id):
		interact_dialogue()
		return

	# Temporaire : ShopManager viendra plus tard.
	print("Open shop: ", data.merchant_shop_id, " for NPC: ", data.id)
	# ShopManager.open_shop(data.merchant_shop_id, data.id)


func get_reputation() -> int:
	if data == null:
		return 0

	return ReputationManager.get_reputation(data.id)


func change_reputation(amount: int) -> void:
	if data == null:
		return

	ReputationManager.change_reputation(data.id, amount)


func get_reputation_level() -> String:
	if data == null:
		return "neutral"

	return ReputationManager.get_reputation_level(data.id)


func can_trade() -> bool:
	if data == null:
		return false

	return ReputationManager.can_trade_with(data.id)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		can_interact = true

		if interaction_prompt != null and data != null:
			interaction_prompt.show_prompt("[E] Talk to " + data.display_name)


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		can_interact = true

		if interaction_prompt != null:
			interaction_prompt.hide_prompt()
