extends CanvasLayer

@onready var power_icon: TextureRect = $MarginContainer/HBoxContainer/PowerIcon
@onready var health_bar: TextureProgressBar = $MarginContainer/HBoxContainer/VBoxContainer/HealthBar
@onready var spirit_bar: TextureProgressBar = $MarginContainer/HBoxContainer/VBoxContainer/SpiritBar
@onready var energy_bar: TextureProgressBar = $MarginContainer/HBoxContainer/VBoxContainer/EnergyBar

@export var fire_icon: Texture2D
@export var water_icon: Texture2D
@export var wood_icon: Texture2D
@export var metal_icon: Texture2D
@export var earth_icon: Texture2D

var current_power := "fire"

func _ready() -> void:
	update_power_icon()
	update_bars(100, 100, 50)

func set_power(power_name: String) -> void:
	current_power = power_name
	update_power_icon()

func update_power_icon() -> void:
	match current_power:
		"fire":
			power_icon.texture = fire_icon
		"water":
			power_icon.texture = water_icon
		"wood":
			power_icon.texture = wood_icon
		"metal":
			power_icon.texture = metal_icon
		"earth":
			power_icon.texture = earth_icon

func update_bars(health: int, spirit: int, energy: int) -> void:
	health_bar.value = health
	spirit_bar.value = spirit
	energy_bar.value = energy
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right"):
		set_power("fire")
	if event.is_action_pressed("ui_left"):
		set_power("water")
