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

var current_power: String = "fire"


func _ready() -> void:
	PlayerStats.health_changed.connect(_on_health_changed)
	PlayerStats.energy_changed.connect(_on_energy_changed)
	PlayerStats.spirit_changed.connect(_on_spirit_changed)

	update_power_icon()
	PlayerStats.emit_all_changed()


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
		_:
			power_icon.texture = fire_icon


func _on_health_changed(current_health: int, max_health: int) -> void:
	health_bar.max_value = max_health
	health_bar.value = current_health


func _on_energy_changed(current_energy: int, max_energy: int) -> void:
	energy_bar.max_value = max_energy
	energy_bar.value = current_energy


func _on_spirit_changed(current_spirit: int, max_spirit: int) -> void:
	spirit_bar.max_value = max_spirit
	spirit_bar.value = current_spirit


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right"):
		set_power("fire")

	if event.is_action_pressed("ui_left"):
		set_power("water")
