extends Resource
class_name NPCData

enum NPCType {
	NORMAL,
	MERCHANT,
	QUEST_GIVER,
	COMPANION,
	ENEMY_NEUTRAL,
	ARCHITECT,
	BLACKSMITH,
	INNKEEPER
}

@export var id: String
@export var display_name: String
@export var npc_type: NPCType = NPCType.NORMAL

@export_file("*.json") var dialogue_path: String = ""

@export_group("Merchant")
@export var merchant_data: MerchantData

@export_group("Architect")
@export var managed_buildings: Array[BuildingData] = []

@export_group("Portraits")
@export var neutral_portrait: Texture2D
@export var happy_portrait: Texture2D
@export var angry_portrait: Texture2D
@export var sad_portrait: Texture2D

@export_group("World Visuals")
@export var world_sprite: Texture2D
@export var visual_scene: PackedScene

@export_group("Reputation")
@export var starting_reputation: int = 0


func get_portrait(emotion: String = "neutral") -> Texture2D:
	match emotion:
		"happy":
			return happy_portrait if happy_portrait != null else neutral_portrait
		"angry":
			return angry_portrait if angry_portrait != null else neutral_portrait
		"sad":
			return sad_portrait if sad_portrait != null else neutral_portrait
		_:
			return neutral_portrait
