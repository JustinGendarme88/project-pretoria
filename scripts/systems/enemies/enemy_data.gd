extends Resource
class_name EnemyData

@export_category("Identity")
@export var enemy_id: String = ""
@export var display_name: String = "Enemy"

@export_category("Visual")
@export var texture: Texture2D
@export var scale_multiplier: float = 1.0

@export_category("Stats")
@export var max_hp: int = 10
@export var attack: int = 2
@export var defense: int = 0
@export var move_speed: float = 60.0

@export_category("Critical Hits")
@export_range(0.0, 1.0, 0.01)
var critical_chance: float = 0.05

@export var critical_multiplier: float = 1.5

@export_category("Element")
@export_enum("None", "Fire", "Water", "Wood", "Metal", "Earth")
var element: String = "None"

@export_category("Combat")
@export_enum("Melee", "Ranged", "Hybrid", "Boss")
var combat_type: String = "Melee"

@export var attack_range: float = 24.0
@export var detection_range: float = 160.0
@export var attack_cooldown: float = 1.0

@export_category("Movement")
@export_enum("Normal", "Slow", "Fast", "Teleport", "Static")
var movement_type: String = "Normal"

@export_category("Rewards")
@export var experience_reward: int = 1
@export var gold_reward: int = 0

@export_category("Loot")
@export var loot_table: Array[Resource] = []
